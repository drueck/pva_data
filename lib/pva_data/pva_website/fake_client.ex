defmodule PVAData.PVAWebsite.FakeClient do
  alias PVAData.PVAWebsite.{
    TeamsParser,
    SchedulesParser,
    ScoresParser,
    StandingsParser
  }

  @behaviour PVAData.PVAWebsite.ClientBehaviour

  def get_teams_by_division() do
    "test/fixtures/schedules.php"
    |> File.read!()
    |> TeamsParser.get_teams_by_division()
  end

  def get_scheduled_matches() do
    "test/fixtures/schedules.php"
    |> File.read!()
    |> SchedulesParser.get_scheduled_matches()
  end

  def get_completed_matches() do
    "test/fixtures/scores.php"
    |> File.read!()
    |> ScoresParser.get_completed_matches()
  end

  def get_division_standings() do
    "test/fixtures/standings.php"
    |> File.read!()
    |> StandingsParser.get_divisions_standings()
  end
end
