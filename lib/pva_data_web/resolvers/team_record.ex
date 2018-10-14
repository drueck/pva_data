defmodule PVADataWeb.Resolvers.TeamRecord do
  alias PVAData.{
    Data,
    Divisions.Division
  }

  def all_for_division(%Division{name: name}, pagination_args, _) do
    name
    |> Data.get_division_standings()
    |> Absinthe.Relay.Connection.from_list(pagination_args)
  end
end
