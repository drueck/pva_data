defmodule PVAData.PVAWebsite.ScoresParser do
  import Meeseeks.CSS

  alias PVAData.PVAWebsite.DateUtils

  alias PVAData.{
    Division,
    Team,
    Match,
    SetResult
  }

  def get_completed_matches(scores_html) do
    scores_html
    |> Meeseeks.all(css("tr"))
    |> Enum.slice(2..-1)
    |> Enum.map(fn row ->
      [date_string, time_string, division_name, home, visitor | set_results_strings] =
        row
        |> Meeseeks.all(css("td"))
        |> Enum.map(&Meeseeks.text/1)

      division = Division.new(name: division_name)
      home_team = Team.new(name: home, division_id: division.id)
      visiting_team = Team.new(name: visitor, division_id: division.id)

      date = DateUtils.parse_date(date_string)
      time = DateUtils.parse_time(time_string)

      match =
        Match.new(
          date: date,
          time: time,
          division_id: division.id,
          home_team_id: home_team.id,
          visiting_team_id: visiting_team.id
        )

      %{match | set_results: set_results_from_strings(set_results_strings, match.id)}
    end)
    |> (fn matches -> {:ok, matches} end).()
  end

  defp set_results_from_strings(set_results_strings, match_id) do
    set_results_strings
    |> Enum.with_index(1)
    |> Enum.map(&set_result_from_string(&1, match_id))
    |> Enum.reject(&is_nil/1)
  end

  defp set_result_from_string({set_result_string, set_number}, match_id) do
    ~r/(?<home>\d+)\s+-\s+(?<visitor>\d+)/
    |> Regex.named_captures(set_result_string)
    |> case do
      nil ->
        nil

      %{"home" => home, "visitor" => visitor} ->
        SetResult.new(
          match_id: match_id,
          set: set_number,
          home: String.to_integer(home),
          visitor: String.to_integer(visitor)
        )
    end
  end
end
