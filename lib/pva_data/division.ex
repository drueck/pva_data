defmodule PVAData.Division do
  use PVAData.ComputedId, keys: [:name]

  alias PVAData.{
    Division,
    Standing,
    Team,
    Match
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

  def build(name) do
    Division.new(
      name: name,
      slug: Slugger.slugify_downcase(name)
    )
  end

  # what the pva website says about how teams are ranked
  # 1. Win percentage
  # 2. Percentage of possible match points
  # 3. Head to head record (if two teams are tied)
  # 4. Points differential in all sets involving the tied teams
  # 5. Points allowed in sets involving the tied teams in sets against each other

  def compare_teams(%Division{} = division, %Team{} = a, %Team{} = b) do
    comparison_functions = [
      &compare_win_percentage/3,
      &compare_match_points_percentage/3,
      &compare_head_to_head/3,
      &compare_points_differential/3,
      &compare_points_allowed_head_to_head/3
    ]

    Enum.reduce(comparison_functions, 0, fn fun, result ->
      if result == 0 do
        fun.(division, a, b)
      else
        result
      end
    end)
  end

  def compare_win_percentage(%Division{} = division, %Team{} = a, %Team{} = b) do
    a_standing = Enum.find(division.standings, &(&1.team_id == a.id))
    b_standing = Enum.find(division.standings, &(&1.team_id == b.id))

    a_standing.winning_percentage - b_standing.winning_percentage
  end

  def compare_match_points_percentage(%Division{} = division, %Team{} = a, %Team{} = b) do
    a_standing = Enum.find(division.standings, &(&1.team_id == a.id))
    b_standing = Enum.find(division.standings, &(&1.team_id == b.id))

    a_standing.match_points_percentage - b_standing.match_points_percentage
  end

  def compare_head_to_head(%Division{} = division, %Team{} = a, %Team{} = b) do
    matches = completed_matches_between_teams(division, a, b)

    team_a_wins = Enum.count(matches, &(Match.result(&1, a) == :win))
    team_b_wins = Enum.count(matches, &(Match.result(&1, b) == :win))

    team_a_wins - team_b_wins
  end

  def compare_points_differential(%Division{} = division, %Team{} = a, %Team{} = b) do
    team_a_points_differential =
      completed_matches_involving_team(division, a)
      |> Enum.map(&Match.point_differential(&1, a))
      |> Enum.sum()

    team_b_points_differential =
      completed_matches_involving_team(division, b)
      |> Enum.map(&Match.point_differential(&1, b))
      |> Enum.sum()

    cond do
      team_a_points_differential > team_b_points_differential -> 1
      team_a_points_differential < team_b_points_differential -> -1
      true -> 0
    end
  end

  def compare_points_allowed_head_to_head(%Division{} = division, %Team{} = a, %Team{} = b) do
    matches = completed_matches_between_teams(division, a, b)

    points_allowed_by_team_a =
      matches
      |> Enum.map(&Match.points_allowed(&1, a))
      |> Enum.sum()

    points_allowed_by_team_b =
      matches
      |> Enum.map(&Match.points_allowed(&1, b))
      |> Enum.sum()

    cond do
      points_allowed_by_team_a < points_allowed_by_team_b -> 1
      points_allowed_by_team_a > points_allowed_by_team_b -> -1
      true -> 0
    end
  end

  defp completed_matches_involving_team(%Division{} = division, %Team{} = team) do
    division.completed_matches
    |> Enum.filter(fn match ->
      match.home_team_id == team.id || match.visiting_team_id == team.id
    end)
  end

  defp completed_matches_between_teams(%Division{} = division, %Team{} = a, %Team{} = b) do
    team_ids = MapSet.new([a.id, b.id])

    division.completed_matches
    |> Enum.filter(fn match ->
      team_ids == MapSet.new([match.home_team_id, match.visiting_team_id])
    end)
  end

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
