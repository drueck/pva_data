defmodule PVAData.PVAWebsite.ScoresParserTest do
  use ExUnit.Case, async: true

  alias PVAData.PVAWebsite.ScoresParser

  alias PVAData.{
    Team,
    Division,
    Match,
    SetResult
  }

  describe "get_completed_matches/1" do
    test "returns a list of matches with set results from scores page body" do
      assert {:ok, matches} =
               "test/fixtures/scores.php"
               |> File.read!()
               |> ScoresParser.get_completed_matches()

      expected_match_count = 26
      current_year = Date.utc_today().year

      {:ok, first_match_date} = Date.new(current_year, 6, 7)

      first_match_division = Division.new(name: "Womens Grass Quads B")

      first_match_home_team = Team.new(name: "Grass Hurts", division_id: first_match_division.id)

      first_match_visiting_team =
        Team.new(name: "Attack Pack", division_id: first_match_division.id)

      expected_first_match =
        Match.new(
          date: first_match_date,
          time: ~T[18:30:00],
          division_id: first_match_division.id,
          home_team_id: first_match_home_team.id,
          visiting_team_id: first_match_visiting_team.id,
          location: nil,
          court: nil,
          ref: nil
        )

      expected_first_match =
        expected_first_match
        |> Map.put(
          :set_results,
          [
            SetResult.new(
              match_id: expected_first_match.id,
              set_number: 1,
              home_team_score: 8,
              visiting_team_score: 21
            ),
            SetResult.new(
              match_id: expected_first_match.id,
              set_number: 2,
              home_team_score: 21,
              visiting_team_score: 19
            ),
            SetResult.new(
              match_id: expected_first_match.id,
              set_number: 3,
              home_team_score: 8,
              visiting_team_score: 15
            )
          ]
        )

      {:ok, last_match_date} = Date.new(current_year, 6, 9)

      last_match_division = Division.new(name: "Womens Sand Quads")

      last_match_home_team = Team.new(name: "Sandbags", division_id: last_match_division.id)

      last_match_visiting_team = Team.new(name: "Waffles", division_id: last_match_division.id)

      expected_last_match =
        Match.new(
          date: last_match_date,
          time: ~T[19:30:00],
          division_id: last_match_division.id,
          home_team_id: last_match_home_team.id,
          visiting_team_id: last_match_visiting_team.id,
          location: nil,
          ref: nil,
          court: nil,
          set_results: []
        )

      expected_last_match =
        expected_last_match
        |> Map.put(
          :set_results,
          [
            SetResult.new(
              match_id: expected_last_match.id,
              set_number: 1,
              home_team_score: 21,
              visiting_team_score: 16
            ),
            SetResult.new(
              match_id: expected_last_match.id,
              set_number: 2,
              home_team_score: 14,
              visiting_team_score: 21
            ),
            SetResult.new(
              match_id: expected_last_match.id,
              set_number: 3,
              home_team_score: 14,
              visiting_team_score: 16
            )
          ]
        )

      assert length(matches) == expected_match_count
      assert List.first(matches) == expected_first_match
      assert List.last(matches) == expected_last_match
    end
  end
end
