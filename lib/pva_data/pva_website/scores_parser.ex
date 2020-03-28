defmodule PVAData.PVAWebsite.ScoresParser do
  import Meeseeks.CSS

  alias PVAData.PVAWebsite.DateUtils

  alias PVAData.{
    Match,
    SetResult
  }

  def get_completed_matches(scores_html) do
    scores_html
    |> Meeseeks.all(css("tr"))
    |> Enum.slice(2..-1)
    |> Enum.map(fn row ->
      [date_string, time_string, division, home, visitor | set_results_strings] =
        row
        |> Meeseeks.all(css("td"))
        |> Enum.map(&Meeseeks.text/1)

      date = DateUtils.parse_date(date_string)
      time = DateUtils.parse_time(time_string)

      match =
        %{
          date: date,
          time: time,
          division: division,
          home: home,
          visitor: visitor
        }
        |> Match.new()

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
        %{
          match_id: match_id,
          set: set_number,
          home: String.to_integer(home),
          visitor: String.to_integer(visitor)
        }
        |> SetResult.new()
    end
  end
end
