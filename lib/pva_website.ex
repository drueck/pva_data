defmodule PVAWebsite do
  alias PVAWebsite.{
    TeamsParser,
    SchedulesParser,
    ScoresParser,
    StandingsParser
  }

  def get_teams_by_division() do
    "https://portlandvolleyball.org/schedules.php"
    |> fetch_and_parse(&TeamsParser.get_teams_by_division/1)
  end

  def get_scheduled_matches() do
    "https://portlandvolleyball.org/schedules.php"
    |> fetch_and_parse(&SchedulesParser.get_scheduled_matches/1)
  end

  def get_scores() do
    "https://portlandvolleyball.org/scores.php"
    |> fetch_and_parse(&ScoresParser.get_scores/1)
  end

  def get_division_standings() do
    "https://portlandvolleyball.org/standings.php"
    |> fetch_and_parse(&StandingsParser.get_divisions_standings/1)
  end

  defp fetch_and_parse(url, parse) do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url) do
      parse.(body)
    end
  end
end
