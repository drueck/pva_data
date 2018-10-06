defmodule PVAData.Application do
  @moduledoc false

  use Application

  alias PVAData.{Data, ScraperBot}

  def start(_type, _args) do
    children = [
      {Data, [name: Data]},
      {ScraperBot, [name: ScraperBot]}
    ]

    opts = [strategy: :one_for_one, name: PVAData.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
