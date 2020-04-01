alias PVAData.{
  Data,
  Standing,
  Match
}

defmodule PVADataWeb.Resolvers.Team do
  def from_standing(%Standing{division_id: division_id, team_id: team_id}, _, _) do
    get(division_id, team_id)
  end

  def home_team_from_match(%Match{division_id: division_id, home_team_id: team_id}, _, _) do
    get(division_id, team_id)
  end

  def visiting_team_from_match(%Match{division_id: division_id, visiting_team_id: team_id}, _, _) do
    get(division_id, team_id)
  end

  defp get(division_id, team_id) do
    team =
      division_id
      |> Data.get_division()
      |> Map.get(:teams)
      |> Enum.find(fn team -> team.id == team_id end)

    {:ok, team}
  end
end
