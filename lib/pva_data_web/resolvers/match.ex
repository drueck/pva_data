defmodule PVADataWeb.Resolvers.Match do
  alias PVAData.{
    Data,
    Divisions.Division
  }

  def scores_for_division(%Division{name: division_name}, pagination_args, _) do
    division_name
    |> sorted_matches_for_division()
    |> Enum.filter(&has_results?/1)
    |> Absinthe.Relay.Connection.from_list(pagination_args)
  end

  def scores_for_team(
        %{name: team_name, division: %Division{name: division_name}},
        pagination_args,
        _
      ) do
    division_name
    |> sorted_matches_for_division()
    |> Enum.filter(&for_team(&1, team_name))
    |> Enum.filter(&has_results?/1)
    |> Absinthe.Relay.Connection.from_list(pagination_args)
  end

  def schedules_for_division(%Division{name: division_name}, pagination_args, _) do
    division_name
    |> sorted_matches_for_division()
    |> Enum.reject(&has_results?/1)
    |> Absinthe.Relay.Connection.from_list(pagination_args)
  end

  def schedules_for_team(
        %{name: team_name, division: %Division{name: division_name}},
        pagination_args,
        _
      ) do
    division_name
    |> sorted_matches_for_division()
    |> Enum.filter(&for_team(&1, team_name))
    |> Enum.reject(&has_results?/1)
    |> Absinthe.Relay.Connection.from_list(pagination_args)
  end

  defp sorted_matches_for_division(division_name) do
    division_name
    |> Data.get_division()
    |> Map.get(:matches)
    |> Enum.sort(&chronological/2)
  end

  defp for_team(match, name) do
    match.home.name == name || match.visitor.name == name
  end

  defp has_results?(match) do
    !is_nil(match.home.games_won) || !is_nil(match.visitor.games_won)
  end

  def chronological(ma, mb) do
    case Date.compare(ma.date, mb.date) do
      :eq -> Time.compare(ma.time, mb.time)
      result -> result
    end
    |> case do
      :gt -> false
      _ -> true
    end
  end
end
