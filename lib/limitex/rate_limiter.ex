defmodule Limitex.RateLimiter do
  @moduledoc """
  A distributed rate limiter for expensive requests based on Token Bucket algorithm.
  """
  use GenServer
  require Logger
  alias :shards, as: Shards
  alias :shards_local, as: ShardsLocal

  @table :limitex
  # Expiry should be longer than the life of the longest bucket.
  @expiry :timer.minutes(15)
  @cleanup_interval :timer.minutes(5)

  # types
  @type bucket_key :: {bucket :: integer, id :: String.t()}
  @type bucket_info ::
          {key :: bucket_key, count :: integer, created :: integer, updated :: integer}

  # ==========
  # Client API
  # ==========

  @doc false
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Check if the action you wish to perform is within the bounds of the rate-limit.
  - `id`: String name of the bucket. Usually comprised of a fixed prefix and some dynamic string appended
  - `scale_ms`: Integer indicating size of bucket in milliseconds
  - `limit`: Integer maximum count of actions within the bucket

  Example:
      user_id = 42076
      case check_rate("file_upload:\#{user_id}", 60_000, 5) do
        {:ok, _count} ->
          # do the file upload
        {:error, :rate_limited} ->
          # render an error page or something
      end
  """
  @spec check_rate(String.t(), integer(), integer(), integer()) ::
          {:ok, integer()} | {:error, :rate_limited} | {:error, :internal_server_error}
  def check_rate(id, scale_ms, limit, increment \\ 1) do
    {now, key} = _stamp_key(id, scale_ms)

    case Shards.update_counter(@table, key, [{2, increment}, {4, 1, 0, now}]) do
      [count, _] when count > limit ->
        {:error, :rate_limited}

      [count, _] ->
        {:ok, count}

      {:badrpc, {:EXIT, {:badarg, _trace}}} ->
        Shards.insert(@table, {key, increment, now, now})
        {:ok, increment}

      _other ->
        {:error, :internal_server_error}
    end
  end

  # ================
  # Server Callbacks
  # ================

  @impl GenServer
  def init(_opts) do
    interval = Application.get_env(:limitex, :cleanup_interval, @cleanup_interval)
    expiry = Application.get_env(:limitex, :expiry, @expiry)
    Logger.info("[Limitex]: Initializing...")

    opts = [
      scope: :g,
      read_concurrency: true,
      write_concurrency: true
    ]

    Shards.new(@table, opts)
    Shards.join(@table, Node.list())
    _schedule_cleanup(interval)
    {:ok, %{interval: interval, expiry: expiry}}
  end

  @impl GenServer
  def handle_info(:clear, state) do
    Shards.join(@table, Node.list())
    expire_before = _now() - state.expiry

    count =
      ShardsLocal.select_delete(@table, [
        {{:_, :_, :_, :"$1"}, [{:<, :"$1", expire_before}], [true]}
      ])

    Logger.debug("[Limitex]: Performing local cleanup... (#{count} items removed)")
    _schedule_cleanup(state.interval)
    {:noreply, state}
  end

  # =================
  # Private Functions
  # =================

  defp _schedule_cleanup(interval) do
    Process.send_after(self(), :clear, interval)
  end

  defp _now do
    System.system_time(:millisecond)
  end

  defp _stamp_key(id, scale_ms) do
    now = _now()
    # with scale_ms = 1 bucket changes every millisecond
    bucket_number = Kernel.trunc(now / scale_ms)
    key = {bucket_number, id}
    {now, key}
  end
end
