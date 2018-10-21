defmodule PVADataWeb.Resolvers.Team do
  alias PVAData.{
    Data,
    Divisions.Division
  }

  def all_for_division(%Division{} = division, pagination_args, _) do
    Data.get_division_standings(division.name)
    |> Enum.map(fn team_record -> build_team(team_record, division) end)
    |> Absinthe.Relay.Connection.from_list(pagination_args)
  end

  def get(%Division{} = division, %{name: name}, _) do
    Data.get_division_standings(division.name)
    |> Enum.find(fn team_record -> team_record.team_name == name end)
    |> case do
      nil -> {:error, "Team not found"}
      team_record -> {:ok, build_team(team_record, division)}
    end
  end

  defp build_team(team_record, division) do
    %{
      id: team_record.id,
      name: team_record.team_name,
      division: division,
      record: team_record
    }
  end
end
