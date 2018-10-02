defmodule PVAData.DivisionDataScraper do
  import Meeseeks.CSS

  alias PVAData.Standings.Standing

  def get_division_data(url) do
    html = HTTPoison.get!(url).body

    %{standings: parse_standings(html), matches: parse_matches(html)}
  end

  defp parse_standings(html) do
    html
    |> Meeseeks.one(css(".standings-table tbody"))
    |> Meeseeks.all(css("tr"))
    |> Enum.map(fn row ->
      [team_name, matches_won, matches_lost, _, matches_back, games_won, games_lost, _] =
        row
        |> Meeseeks.all(css("td"))
        |> Enum.map(&Meeseeks.text/1)

      {matches_back_float, _} = Float.parse(matches_back)

      %Standing{
        team_name: team_name,
        matches_won: String.to_integer(matches_won),
        matches_lost: String.to_integer(matches_lost),
        matches_back: matches_back_float,
        games_won: String.to_integer(games_won),
        games_lost: String.to_integer(games_lost)
      }
    end)
  end

  defp parse_matches(html) do
    html
    |> Meeseeks.all(css(".game-list-table tr"))
    |> Enum.reduce({nil, nil, []}, fn tr, {current_date, current_match, matches} ->
      cond do
        match_date_row?(tr) ->
          with date <- date(tr), do: {date, %{date: date}, matches}

        first_team_row?(tr) ->
          updated_match =
            current_match
            |> Map.put(:time, time(tr))
            |> Map.put(:location, %{
              name: location_name(tr),
              map_url: map_url(tr)
            })
            |> Map.put(home_or_visitor(tr), %{
              name: team_name(tr),
              games_won: games_won(tr)
            })

          {current_date, updated_match, matches}

        second_team_row?(tr) ->
          updated_match =
            current_match
            |> Map.put(home_or_visitor(tr), %{
              name: team_name(tr),
              games_won: games_won(tr)
            })

          {current_date, %{}, [updated_match | matches]}

        true ->
          {current_date, current_match, matches}
      end
    end)
    |> (fn {_, _, matches} -> Enum.reverse(matches) end).()
  end

  defp match_date_row?(tr), do: !is_nil(Meeseeks.one(tr, css(".game-list-date")))
  defp first_team_row?(tr), do: Meeseeks.attr(tr, "class") == "game-list-row-top"
  defp second_team_row?(tr), do: Meeseeks.attr(tr, "class") == "game-list-row-bottom"

  defp date(tr) do
    tr
    |> Meeseeks.one(css(".game-list-date-anchor"))
    |> Meeseeks.attr("name")
    |> Date.from_iso8601!()
  end

  defp time(tr) do
    [hour, minutes] =
      tr
      |> Meeseeks.one(css(".game-list-left span:first-child"))
      |> Meeseeks.text()
      |> String.split(" ")
      |> hd()
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)

    am_or_pm =
      tr
      |> Meeseeks.one(css(".game-list-time-am"))
      |> Meeseeks.text()
      |> String.trim()
      |> String.downcase()

    hour =
      case am_or_pm do
        "am" -> hour
        "pm" -> hour + 12
      end

    with {:ok, time} <- Time.new(hour, minutes, 0), do: time
  end

  defp location_name(tr) do
    tr
    |> Meeseeks.one(css(".game-list-right-location"))
    |> Meeseeks.text()
  end

  defp map_url(tr) do
    tr
    |> Meeseeks.one(css(".game-list-map a"))
    |> Meeseeks.attr("href")
  end

  defp home_or_visitor(tr) do
    case Meeseeks.one(tr, css(".game-list-team-home")) do
      nil -> :visitor
      _ -> :home
    end
  end

  defp team_name(tr) do
    tr
    |> Meeseeks.one(css(".game-list-team a"))
    |> Meeseeks.text()
  end

  defp games_won(tr) do
    tr
    |> Meeseeks.one(css(".game-list-score"))
    |> Meeseeks.text()
    |> case do
      "" -> nil
      nil -> nil
      wins -> String.to_integer(wins)
    end
  end
end
