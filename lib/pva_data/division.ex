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
    trimmed_name = String.trim(name)

    Division.new(
      name: trimmed_name,
      slug: Slugger.slugify_downcase(trimmed_name)
    )
  end

  # What the team sideline pva site says about how teams are ranked:
  # 1. Winning Percentage
  # 2. Average Points Differential
  # 3. Total Wins
  # 4. Total Points For
  # 5. Total Points Differential
  # 6. Total Points Against
  # 8. Coin Toss

  def compare_teams(
        %Division{} = division,
        %Team{} = a,
        %Team{} = b,
        save_rank_data \\ fn _, _ -> :noop end
      ) do
    [
      &compare_winning_percentage/3,
      &compare_average_points_differential/3,
      &compare_total_wins/3,
      &compare_total_points_for/3,
      &compare_total_points_differential/3,
      &compare_total_points_against/3,
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

  def compare_winning_percentage(%Division{} = division, %Team{} = a, %Team{} = b) do
    a_standing = Enum.find(division.standings, &(&1.team_id == a.id))
    b_standing = Enum.find(division.standings, &(&1.team_id == b.id))

    stat = "winning percentage"

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

  def compare_average_points_differential(%Division{} = division, %Team{} = a, %Team{} = b) do
    team_a_avg_points_differential =
      completed_matches_involving_team(division, a)
      |> Enum.map(&Match.point_differential(&1, a))
      |> then(fn point_differentials ->
        if Enum.empty?(point_differentials),
          do: 0,
          else: Float.round(Enum.sum(point_differentials) / Enum.count(point_differentials), 3)
      end)

    team_b_avg_points_differential =
      completed_matches_involving_team(division, b)
      |> Enum.map(&Match.point_differential(&1, b))
      |> then(fn point_differentials ->
        if Enum.empty?(point_differentials),
          do: 0,
          else: Float.round(Enum.sum(point_differentials) / Enum.count(point_differentials), 3)
      end)

    stat = "average points differential"

    rank_data = %{
      a.id => {stat, team_a_avg_points_differential},
      b.id => {stat, team_b_avg_points_differential}
    }

    result =
      cond do
        team_a_avg_points_differential > team_b_avg_points_differential -> 1
        team_a_avg_points_differential < team_b_avg_points_differential -> -1
        true -> 0
      end

    {result, rank_data}
  end

  def compare_total_wins(%Division{} = division, %Team{} = a, %Team{} = b) do
    team_a_wins =
      completed_matches_involving_team(division, a)
      |> Enum.count(&(Match.result(&1, a) == :win))

    team_b_wins =
      completed_matches_involving_team(division, b)
      |> Enum.count(&(Match.result(&1, b) == :win))

    stat = "total wins"

    rank_data = %{
      a.id => {stat, team_a_wins},
      b.id => {stat, team_b_wins}
    }

    {team_a_wins - team_b_wins, rank_data}
  end

  def compare_total_points_for(%Division{} = division, %Team{} = a, %Team{} = b) do
    team_a_total_points =
      completed_matches_involving_team(division, a)
      |> Enum.map(&Match.points_scored(&1, a))
      |> Enum.sum()

    team_b_total_points =
      completed_matches_involving_team(division, b)
      |> Enum.map(&Match.points_scored(&1, b))
      |> Enum.sum()

    stat = "total points for"

    rank_data = %{
      a.id => {stat, team_a_total_points},
      b.id => {stat, team_b_total_points}
    }

    {team_a_total_points - team_b_total_points, rank_data}
  end

  def compare_total_points_differential(%Division{} = division, %Team{} = a, %Team{} = b) do
    team_a_points_differential =
      completed_matches_involving_team(division, a)
      |> Enum.map(&Match.point_differential(&1, a))
      |> Enum.sum()

    team_b_points_differential =
      completed_matches_involving_team(division, b)
      |> Enum.map(&Match.point_differential(&1, b))
      |> Enum.sum()

    stat = "total points differential"

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

  def compare_total_points_against(%Division{} = division, %Team{} = a, %Team{} = b) do
    team_a_points_allowed =
      completed_matches_involving_team(division, a)
      |> Enum.map(&Match.points_allowed(&1, a))
      |> Enum.sum()

    team_b_points_allowed =
      completed_matches_involving_team(division, b)
      |> Enum.map(&Match.points_allowed(&1, b))
      |> Enum.sum()

    stat = "total points against"

    rank_data = %{
      a.id => {stat, team_a_points_allowed},
      b.id => {stat, team_b_points_allowed}
    }

    {team_b_points_allowed - team_a_points_allowed, rank_data}
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

  def completed_matches_involving_team(%Division{} = division, %Team{} = team) do
    completed_matches_involving_team(division, team.id)
  end

  def completed_matches_involving_team(%Division{} = division, team_id) do
    division.completed_matches
    |> Enum.filter(fn match ->
      match.home_team_id == team_id || match.visiting_team_id == team_id
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
