defmodule PVAData.PVAWebsite.FakeClient do
  alias PVAData.PVAWebsite.{
    TeamsParser,
    SchedulesParser,
    ScoresParser,
    StandingsParser
  }

  @behaviour PVAData.PVAWebsite.ClientBehaviour

  @base_path "test/fixtures"

  def login(_password, _base_path), do: {:ok, []}

  def get_teams_by_division(base_path \\ nil, _cookies \\ []) do
    "#{base_path || @base_path}/schedules.php"
    |> File.read!()
    |> TeamsParser.get_teams_by_division()
  end

  def get_scheduled_matches(base_path \\ nil, _cookies \\ []) do
    "#{base_path || @base_path}/schedules.php"
    |> File.read!()
    |> SchedulesParser.get_scheduled_matches()
  end

  def get_completed_matches(base_path \\ nil, _cookies \\ []) do
    "#{base_path || @base_path}/scores.php"
    |> File.read!()
    |> ScoresParser.get_completed_matches()
  end

  def get_division_standings(base_path \\ nil, _cookies \\ []) do
    "#{base_path || @base_path}/standings.php"
    |> File.read!()
    |> StandingsParser.get_divisions_standings()
  end
end
