defmodule PVAData.PVAWebsite.SchedulesParserTest do
  use ExUnit.Case, async: true

  alias PVAData.PVAWebsite.SchedulesParser

  alias PVAData.{
    Team,
    Match,
    Division
  }

  describe "get_scheduled_matches/1" do
    test "returns a list of matches from the schedules page body" do
      assert {:ok, matches} =
               "test/fixtures/schedules.php"
               |> File.read!()
               |> SchedulesParser.get_scheduled_matches()

      expected_match_count = 28
      current_year = Date.utc_today().year

      {:ok, first_match_date} = Date.new(current_year, 4, 8)

      first_match_division = Division.new(name: "Womens BB")
      first_match_home_team = Team.new(name: "Ball Busters", division_id: first_match_division.id)

      first_match_visiting_team =
        Team.new(name: "Floor Burn", division_id: first_match_division.id)

      expected_first_match =
        Match.new(
          date: first_match_date,
          time: ~T[19:00:00],
          division_id: first_match_division.id,
          home_team_id: first_match_home_team.id,
          visiting_team_id: first_match_visiting_team.id,
          location: "St. Johns Community Center",
          ref: "Jim R.",
          set_results: []
        )

      {:ok, last_match_date} = Date.new(current_year, 4, 10)

      last_match_division = Division.new(name: "Coed A Wednesday")
      last_match_home_team = Team.new(name: "Merda Mafia", division_id: last_match_division.id)

      last_match_visiting_team =
        Team.new(name: "Hit it N Dig It", division_id: last_match_division.id)

      expected_last_match =
        Match.new(
          date: last_match_date,
          time: ~T[21:00:00],
          division_id: last_match_division.id,
          home_team_id: last_match_home_team.id,
          visiting_team_id: last_match_visiting_team.id,
          location: "East Portland Community Center",
          ref: "Marshal R.",
          set_results: []
        )

      assert length(matches) == expected_match_count

      matches
      |> Enum.each(fn match -> assert %Match{} = match end)

      assert expected_first_match == List.first(matches)
      assert expected_last_match == List.last(matches)
    end
  end
end
