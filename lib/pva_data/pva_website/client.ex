defmodule PVAData.PVAWebsite.Client do
  alias PVAData.PVAWebsite.{
    TeamsParser,
    SchedulesParser,
    ScoresParser,
    StandingsParser
  }

  @behaviour PVAData.PVAWebsite.ClientBehaviour

  @base_path "https://portlandvolleyball.org"

  def get_teams_by_division(base_path \\ nil) do
    "#{base_path || @base_path}/schedules.php"
    |> fetch_and_parse(&TeamsParser.get_teams_by_division/1)
  end

  def get_scheduled_matches(base_path \\ nil) do
    "#{base_path || @base_path}/schedules.php"
    |> fetch_and_parse(&SchedulesParser.get_scheduled_matches/1)
  end

  def get_completed_matches(base_path \\ nil) do
    "#{base_path || @base_path}/scores.php"
    |> fetch_and_parse(&ScoresParser.get_completed_matches/1)
  end

  def get_division_standings(base_path \\ nil) do
    "#{base_path || @base_path}/standings.php"
    |> fetch_and_parse(&StandingsParser.get_divisions_standings/1)
  end

  defp fetch_and_parse(url, parse) do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url) do
      parse.(body)
    end
  end
end
