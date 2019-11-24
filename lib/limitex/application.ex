defmodule Limitex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Limitex.RateLimiter
    ]

    opts = [strategy: :one_for_one, name: Limitex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
