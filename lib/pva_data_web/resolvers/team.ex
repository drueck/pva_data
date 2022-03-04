alias PVAData.{
  Data,
  Standing,
  Match,
  RankReason
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

  def team_from_rank_reason(%RankReason{} = rank_reason, _, _) do
    get(rank_reason.division_id, rank_reason.team_id)
  end

  def lower_team_from_rank_reason(%RankReason{} = rank_reason, _, _) do
    get(rank_reason.division_id, rank_reason.lower_team_id)
  end

  def by_slugs(%{division_slug: division_slug, team_slug: team_slug}, _) do
    team =
      division_slug
      |> Data.get_division_by_slug()
      |> Map.get(:teams)
      |> Enum.find(fn team -> team.slug == team_slug end)

    {:ok, team}
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
