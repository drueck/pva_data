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
    # just use the order from the pva website for now,
    # since it implements the tie-breakers
    rank_map =
      standings
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {%Standing{team_id: team_id}, rank}, rank_map ->
        Map.put(rank_map, team_id, rank)
      end)

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
end
