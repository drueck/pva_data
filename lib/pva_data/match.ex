defmodule PVAData.Match do
  use PVAData.ComputedId, keys: [:date, :time, :division_id, :home_team_id, :visiting_team_id]

  alias PVAData.{
    Team,
    Match,
    SetResult
  }

  defstruct [
    :id,
    :date,
    :time,
    :division_id,
    :home_team_id,
    :visiting_team_id,
    :location_name,
    :location_url,
    set_results: []
  ]

  def add_set_results(%Match{} = match, scores) do
    set_results =
      scores
      |> Enum.with_index(1)
      |> Enum.map(fn {{home_team_score, visiting_team_score}, set_number} ->
        SetResult.new(
          match_id: match.id,
          set_number: set_number,
          home_team_score: home_team_score,
          visiting_team_score: visiting_team_score
        )
      end)

    %{match | set_results: set_results}
  end

  def sets_won(%Match{} = match, %Team{id: team_id}) do
    sets_won(match, team_id)
  end

  def sets_won(%Match{set_results: set_results} = match, team_id) do
    set_results
    |> Enum.filter(fn set_result ->
      team_score = Map.get(set_result, team_score_key(match, team_id))
      opponent_score = Map.get(set_result, oppononent_score_key(match, team_id))

      team_score > opponent_score
    end)
    |> Enum.count()
  end

  def sets_lost(%Match{} = match, %Team{id: team_id}) do
    sets_lost(match, team_id)
  end

  def sets_lost(%Match{set_results: set_results} = match, team_id) do
    set_results
    |> Enum.filter(fn set_result ->
      team_score = Map.get(set_result, team_score_key(match, team_id))
      opponent_score = Map.get(set_result, oppononent_score_key(match, team_id))

      team_score < opponent_score
    end)
    |> Enum.count()
  end

  def sets_forfeited(%Match{} = match, %Team{id: team_id}) do
    sets_forfeited(match, team_id)
  end

  # for our purposes we'll say a set where a team scores 0 was a forfeit
  def sets_forfeited(%Match{set_results: set_results} = match, team_id) do
    set_results
    |> Enum.filter(fn set_result ->
      Map.get(set_result, team_score_key(match, team_id)) == 0
    end)
    |> Enum.count()
  end

  def point_differential(%Match{} = match, %Team{id: team_id}) do
    point_differential(match, team_id)
  end

  def point_differential(%Match{set_results: set_results} = match, team_id) do
    set_results
    |> Enum.map(fn set_result ->
      team_score = Map.get(set_result, team_score_key(match, team_id))
      opponent_score = Map.get(set_result, oppononent_score_key(match, team_id))
      team_score - opponent_score
    end)
    |> Enum.sum()
  end

  def points_scored(%Match{} = match, %Team{id: team_id}) do
    points_scored(match, team_id)
  end

  def points_scored(%Match{set_results: set_results} = match, team_id) do
    set_results
    |> Enum.map(fn set_result ->
      Map.get(set_result, team_score_key(match, team_id))
    end)
    |> Enum.sum()
  end

  def points_allowed(%Match{} = match, %Team{id: team_id}) do
    points_allowed(match, team_id)
  end

  def points_allowed(%Match{set_results: set_results} = match, team_id) do
    set_results
    |> Enum.map(fn set_result ->
      Map.get(set_result, oppononent_score_key(match, team_id))
    end)
    |> Enum.sum()
  end

  def result(%Match{} = match, %Team{id: team_id}) do
    result(match, team_id)
  end

  def result(%Match{} = match, team_id) do
    sets_won = sets_won(match, team_id)
    sets_lost = sets_lost(match, team_id)

    if sets_won == sets_lost do
      result_by_point_differential(match, team_id)
    else
      if sets_won > sets_lost, do: :win, else: :loss
    end
  end

  def match_points(%Match{} = match, %Team{id: team_id}) do
    match_points(match, team_id)
  end

  def match_points(%Match{} = match, team_id) do
    match_points_for_winning_sets(match, team_id) +
      match_points_for_point_differential(match, team_id) +
      match_points_for_winning_match(match, team_id)
  end

  defp match_points_for_winning_sets(match, team_id) do
    sets_won(match, team_id) * 0.5
  end

  defp match_points_for_point_differential(match, team_id) do
    if point_differential(match, team_id) > 0, do: 1, else: 0
  end

  defp match_points_for_winning_match(match, team_id) do
    if result(match, team_id) == :win, do: 2, else: 0
  end

  defp result_by_point_differential(%Match{} = match, team_id) do
    point_differential = point_differential(match, team_id)

    cond do
      point_differential > 0 -> :win
      point_differential < 0 -> :loss
      true -> :tie
    end
  end

  defp team_score_key(%Match{home_team_id: home_team_id}, team_id) do
    if team_id == home_team_id do
      :home_team_score
    else
      :visiting_team_score
    end
  end

  defp oppononent_score_key(%Match{} = match, team_id) do
    if team_score_key(match, team_id) == :home_team_score do
      :visiting_team_score
    else
      :home_team_score
    end
  end
end
