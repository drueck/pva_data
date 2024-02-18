alias PVAData.{
  Data,
  Team,
  Match
}

defmodule PVADataWeb.Resolvers.Match do
  def completed_for_team(%Team{division_id: division_id, id: team_id}, _, _) do
    matches =
      division_id
      |> completed_matches()
      |> for_team(team_id)

    {:ok, matches}
  end

  def scheduled_for_team(%Team{division_id: division_id, id: team_id}, _, _) do
    matches =
      division_id
      |> scheduled_matches()
      |> for_team(team_id)

    {:ok, matches}
  end

  def scheduled_for_date(%{date: date}, _) do
    {:ok, Data.get_scheduled_matches_by_date(date)}
  end

  defp completed_matches(division_id) do
    division_id
    |> Data.get_division()
    |> Map.get(:completed_matches)
  end

  defp scheduled_matches(division_id) do
    division_id
    |> Data.get_division()
    |> Map.get(:scheduled_matches)
  end

  defp for_team(matches, team_id) do
    matches
    |> Enum.filter(fn %Match{home_team_id: home_team_id, visiting_team_id: visiting_team_id} ->
      home_team_id == team_id || visiting_team_id == team_id
    end)
  end
end
