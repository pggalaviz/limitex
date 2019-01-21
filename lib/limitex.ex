defmodule Limitex do
  @moduledoc """
  A pure Elixir distributed rate limiter based on Token Bucket algorithm.
  """
  alias Limitex.RateLimiter

  defdelegate check_rate(id, scale_ms, limit, increment \\ 1), to: RateLimiter
end
