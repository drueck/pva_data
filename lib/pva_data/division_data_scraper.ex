defmodule PVAData.DivisionDataScraper do
  import Meeseeks.CSS

  def get_division_data(url) do
    html = HTTPoison.get!(url).body

    %{standings: parse_standings(html), schedules: []}
  end

  defp parse_standings(html) do
    html
    |> Meeseeks.one(css(".standings-table tbody"))
    |> Meeseeks.all(css("tr"))
    |> Enum.map(fn row ->
      [name, matches_won, matches_lost, _, matches_back, games_won, games_lost, _] =
        row
        |> Meeseeks.all(css("td"))
        |> Enum.map(&Meeseeks.text/1)

      {matches_back_float, _} = Float.parse(matches_back)

      %{
        name: name,
        matches_won: String.to_integer(matches_won),
        matches_lost: String.to_integer(matches_lost),
        matches_back: matches_back_float,
        games_won: String.to_integer(games_won),
        games_lost: String.to_integer(games_lost)
      }
    end)
  end
end
