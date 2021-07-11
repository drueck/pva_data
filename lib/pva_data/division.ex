defmodule PVAData.Division do
  use PVAData.ComputedId, keys: [:name]

  alias PVAData.{
    Division,
    Standing
  }

  defstruct [
    :id,
    :name,
    :slug,
    teams: [],
    standings: [],
    scheduled_matches: [],
    completed_matches: []
  ]

  def add_ranks(%Division{standings: standings, teams: teams} = division) do
    rank_map =
      standings
      |> Enum.group_by(&rank_points/1)
      |> Enum.sort(&(elem(&1, 0) > elem(&2, 0)))
      |> Enum.reduce({1, %{}}, &build_rank_map_reducer/2)
      |> elem(1)

    teams =
      teams
      |> Enum.map(fn team ->
        %{team | rank: Map.get(rank_map, team.id)}
      end)

    standings =
      standings
      |> Enum.map(fn standing ->
        %{standing | rank: Map.get(rank_map, standing.team_id)}
      end)

    %{division | teams: teams, standings: standings}
  end

  defp rank_points(%Standing{
         winning_percentage: winning_percentage,
         match_points_percentage: match_points_percentage
       }) do
    winning_percentage * 10 + match_points_percentage
  end

  defp build_rank_map_reducer({_rank_points, standings}, {rank, rank_map}) do
    new_rank_map =
      Enum.reduce(standings, rank_map, fn %Standing{team_id: team_id}, rank_map ->
        Map.put(rank_map, team_id, rank)
      end)

    {rank + 1, new_rank_map}
  end
end
