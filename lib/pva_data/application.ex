defmodule PVAData.Application do
  @moduledoc false

  use Application

  alias PVAData.{Data, ScraperBot, Router}

  def start(_type, _args) do
    children = [
      {Data, [name: Data]},
      {ScraperBot, [name: ScraperBot]},
      Plug.Adapters.Cowboy2.child_spec(scheme: :http, plug: Router, options: [port: 9001])
    ]

    opts = [strategy: :one_for_one, name: PVAData.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
