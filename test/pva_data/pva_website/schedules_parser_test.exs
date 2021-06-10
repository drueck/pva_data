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

      expected_match_count = 177
      current_year = Date.utc_today().year

      {:ok, first_match_date} = Date.new(current_year, 6, 9)

      first_match_division = Division.new(name: "Womens Sand Quads")
      first_match_home_team = Team.new(name: "Waffles", division_id: first_match_division.id)

      first_match_visiting_team =
        Team.new(name: "Serve-ivors", division_id: first_match_division.id)

      expected_first_match =
        Match.new(
          date: first_match_date,
          time: ~T[18:30:00],
          division_id: first_match_division.id,
          home_team_id: first_match_home_team.id,
          visiting_team_id: first_match_visiting_team.id,
          location: "Delta Park",
          court: nil,
          ref: nil,
          set_results: []
        )

      {:ok, last_match_date} = Date.new(current_year, 7, 21)

      last_match_division = Division.new(name: "Womens Sand Quads")
      last_match_home_team = Team.new(name: "Serve-ivors", division_id: last_match_division.id)
      last_match_visiting_team = Team.new(name: "Pancakes", division_id: last_match_division.id)

      expected_last_match =
        Match.new(
          date: last_match_date,
          time: ~T[19:30:00],
          division_id: last_match_division.id,
          home_team_id: last_match_home_team.id,
          visiting_team_id: last_match_visiting_team.id,
          location: "Delta Park",
          court: nil,
          ref: nil,
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
