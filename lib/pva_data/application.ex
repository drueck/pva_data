defmodule PVAData.Application do
  @moduledoc false

  use Application

  # alias PVAData.{Data, ScraperBot, Router}
  alias PVAData.Router

  def start(_type, _args) do
    children = [
      # {Data, [name: Data]},
      # {ScraperBot, [name: ScraperBot]},
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: Router,
        options: [port: Application.get_env(:pva_data, :port) |> IO.inspect()]
      )
    ]

    opts = [strategy: :one_for_one, name: PVAData.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
