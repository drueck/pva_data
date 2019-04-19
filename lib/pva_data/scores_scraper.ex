defmodule PVAData.ScoresScraper do
  import Meeseeks.CSS

  alias PVAData.{
    Match,
    SetResult,
    DateUtils
  }

  def get_scores(scores_html) do
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

      %Match{
        date: date,
        time: time,
        division: division,
        home: home,
        visitor: visitor,
        set_results: set_results_from_strings(set_results_strings)
      }
    end)
    |> (fn matches -> {:ok, matches} end).()
  end

  defp set_results_from_strings(set_results_strings) do
    set_results_strings
    |> Enum.with_index(1)
    |> Enum.map(&set_result_from_string/1)
    |> Enum.reject(&is_nil/1)
  end

  defp set_result_from_string({set_result_string, set_number}) do
    ~r/(?<home>\d+)\s+-\s+(?<visitor>\d+)/
    |> Regex.named_captures(set_result_string)
    |> case do
      nil ->
        nil

      %{"home" => home, "visitor" => visitor} ->
        %SetResult{
          set: set_number,
          home: String.to_integer(home),
          visitor: String.to_integer(visitor)
        }
    end
  end
end
