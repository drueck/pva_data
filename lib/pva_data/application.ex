defmodule PVAData.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    other_children = Application.get_env(:pva_data, :other_children)

    children =
      other_children ++
        [
          Plug.Cowboy.child_spec(
            scheme: :http,
            plug: PVAData.Router,
            options: [port: Application.get_env(:pva_data, :port)]
          )
        ]

    opts = [strategy: :one_for_one, name: PVAData.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
