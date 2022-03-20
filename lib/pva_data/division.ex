defmodule PVAData.Division do
  use PVAData.ComputedId, keys: [:name]

  alias PVAData.{
    Division,
    Team,
    Match,
    RankReason,
    TeamRankData
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

  def compare_teams(
        %Division{} = division,
        %Team{} = a,
        %Team{} = b,
        save_rank_data \\ fn _, _ -> :noop end
      ) do
    [
      &compare_win_percentage/3,
      &compare_match_points_percentage/3,
      &compare_head_to_head_match_points/3,
      &compare_head_to_head_points_differential/3,
      &compare_points_differential/3,
      &compare_points_allowed_head_to_head/3,
      &compare_names/3
    ]
    |> Enum.reduce({0, nil}, fn fun, {result, rank_data} ->
      if result == 0 do
        fun.(division, a, b)
      else
        {result, rank_data}
      end
    end)
    |> case do
      {result, rank_data} when result < 0 ->
        save_rank_data.({b.id, a.id}, rank_data)
        false

      {_, rank_data} ->
        save_rank_data.({a.id, b.id}, rank_data)
        true
    end
  end

  def compare_win_percentage(%Division{} = division, %Team{} = a, %Team{} = b) do
    a_standing = Enum.find(division.standings, &(&1.team_id == a.id))
    b_standing = Enum.find(division.standings, &(&1.team_id == b.id))

    stat = "win percentage"

    rank_data = %{
      a.id => {stat, a_standing.winning_percentage},
      b.id => {stat, b_standing.winning_percentage}
    }

    result =
      cond do
        a_standing.winning_percentage > b_standing.winning_percentage -> 1
        a_standing.winning_percentage < b_standing.winning_percentage -> -1
        true -> 0
      end

    {result, rank_data}
  end

  def compare_match_points_percentage(%Division{} = division, %Team{} = a, %Team{} = b) do
    a_standing = Enum.find(division.standings, &(&1.team_id == a.id))
    b_standing = Enum.find(division.standings, &(&1.team_id == b.id))

    stat = "percentage of possible match points"

    rank_data = %{
      a.id => {stat, a_standing.match_points_percentage},
      b.id => {stat, b_standing.match_points_percentage}
    }

    result =
      cond do
        a_standing.match_points_percentage > b_standing.match_points_percentage -> 1
        a_standing.match_points_percentage < b_standing.match_points_percentage -> -1
        true -> 0
      end

    {result, rank_data}
  end

  def compare_head_to_head_match_points(%Division{} = division, %Team{} = a, %Team{} = b) do
    matches = completed_matches_between_teams(division, a, b)

    team_a_match_points = Enum.map(matches, &Match.match_points(&1, a)) |> Enum.sum()
    team_b_match_points = Enum.map(matches, &Match.match_points(&1, b)) |> Enum.sum()

    stat = "head to head record (match points)"

    rank_data = %{
      a.id => {stat, team_a_match_points},
      b.id => {stat, team_b_match_points}
    }

    {team_a_match_points - team_b_match_points, rank_data}
  end

  def compare_head_to_head_points_differential(%Division{} = division, %Team{} = a, %Team{} = b) do
    matches = completed_matches_between_teams(division, a, b)

    team_a_points_differential = Enum.map(matches, &Match.point_differential(&1, a)) |> Enum.sum()
    team_b_points_differential = Enum.map(matches, &Match.point_differential(&1, b)) |> Enum.sum()

    stat = "head to head record (points differential)"

    rank_data = %{
      a.id => {stat, team_a_points_differential},
      b.id => {stat, team_b_points_differential}
    }

    {team_a_points_differential - team_b_points_differential, rank_data}
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

    stat = "points differential in all sets"

    rank_data = %{
      a.id => {stat, team_a_points_differential},
      b.id => {stat, team_b_points_differential}
    }

    result =
      cond do
        team_a_points_differential > team_b_points_differential -> 1
        team_a_points_differential < team_b_points_differential -> -1
        true -> 0
      end

    {result, rank_data}
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

    stat = "points allowed head to head"

    rank_data = %{
      a.id => {stat, points_allowed_by_team_a},
      b.id => {stat, points_allowed_by_team_b}
    }

    {points_allowed_by_team_b - points_allowed_by_team_a, rank_data}
  end

  def compare_names(_, %Team{} = a, %Team{} = b) do
    stat = "team name"

    result =
      cond do
        b.name > a.name -> 1
        b.name < a.name -> -1
        true -> 0
      end

    rank_data = %{
      a.id => {stat, a.name},
      b.id => {stat, b.name}
    }

    {result, rank_data}
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
    {:ok, team_rank_data} = TeamRankData.start_link()

    save_rank_data = fn team_ids, rank_data ->
      TeamRankData.put(team_rank_data, team_ids, rank_data)
    end

    sorted_teams =
      teams
      |> Enum.sort(fn a, b -> compare_teams(division, a, b, save_rank_data) end)

    [top_team | _] = sorted_teams

    rank_map = %{top_team.id => 1}

    rank_map =
      sorted_teams
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(rank_map, fn [%Team{id: up_team_id}, %Team{id: down_team_id}], rank_map ->
        up_team_rank = Map.get(rank_map, up_team_id)

        case TeamRankData.get(team_rank_data, {up_team_id, down_team_id}) do
          # if the rank data statistic is "team name", that means the only tie breaker is
          # an alphabetical sort, so we should rank this team the same as the previous team
          %{^down_team_id => {"team name", _}} ->
            Map.put(rank_map, down_team_id, up_team_rank)

          _ ->
            Map.put(rank_map, down_team_id, up_team_rank + 1)
        end
      end)

    rank_reason_map =
      sorted_teams
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(%{}, fn [%Team{id: up_team_id}, %Team{id: down_team_id}], rank_reason_map ->
        case TeamRankData.get(team_rank_data, {up_team_id, down_team_id}) do
          nil ->
            rank_reason_map

          rank_data ->
            rank_reason =
              RankReason.new(
                team_id: up_team_id,
                division_id: division.id,
                lower_team_id: down_team_id,
                statistic: elem(rank_data[up_team_id], 0),
                team_value: elem(rank_data[up_team_id], 1),
                lower_team_value: elem(rank_data[down_team_id], 1)
              )

            Map.put(rank_reason_map, up_team_id, rank_reason)
        end
      end)

    teams =
      sorted_teams
      |> Enum.map(fn team ->
        team
        |> Map.put(:rank, Map.get(rank_map, team.id))
        |> Map.put(:rank_reason, Map.get(rank_reason_map, team.id))
      end)

    standings =
      standings
      |> Enum.map(fn standing ->
        standing
        |> Map.put(:rank, Map.get(rank_map, standing.team_id))
        |> Map.put(:rank_reason, Map.get(rank_reason_map, standing.team_id))
      end)

    %{division | teams: teams, standings: standings}
  end
end
