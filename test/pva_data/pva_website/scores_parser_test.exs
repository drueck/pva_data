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

      expected_match_count = 8
      current_year = Date.utc_today().year

      {:ok, first_match_date} = Date.new(current_year, 4, 8)

      first_match_division = Division.new(name: "Womens A1 Monday")

      first_match_home_team =
        Team.new(name: "Hot Piece of Ace MON", division_id: first_match_division.id)

      first_match_visiting_team =
        Team.new(name: "Lollipop Girls", division_id: first_match_division.id)

      expected_first_match =
        Match.new(
          date: first_match_date,
          time: ~T[19:00:00],
          division_id: first_match_division.id,
          home_team_id: first_match_home_team.id,
          visiting_team_id: first_match_visiting_team.id,
          location: nil,
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
              home_team_score: 25,
              visiting_team_score: 11
            ),
            SetResult.new(
              match_id: expected_first_match.id,
              set_number: 2,
              home_team_score: 27,
              visiting_team_score: 25
            ),
            SetResult.new(
              match_id: expected_first_match.id,
              set_number: 3,
              home_team_score: 15,
              visiting_team_score: 11
            )
          ]
        )

      {:ok, last_match_date} = Date.new(current_year, 4, 9)

      last_match_division = Division.new(name: "Womens AA Tuesday")

      last_match_home_team =
        Team.new(name: "Natural Diaster", division_id: last_match_division.id)

      last_match_visiting_team =
        Team.new(name: "Sneaker Wave", division_id: last_match_division.id)

      expected_last_match =
        Match.new(
          date: last_match_date,
          time: ~T[20:00:00],
          division_id: last_match_division.id,
          home_team_id: last_match_home_team.id,
          visiting_team_id: last_match_visiting_team.id,
          location: nil,
          ref: nil,
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
              home_team_score: 25,
              visiting_team_score: 21
            ),
            SetResult.new(
              match_id: expected_last_match.id,
              set_number: 2,
              home_team_score: 15,
              visiting_team_score: 25
            ),
            SetResult.new(
              match_id: expected_last_match.id,
              set_number: 3,
              home_team_score: 15,
              visiting_team_score: 11
            )
          ]
        )

      assert length(matches) == expected_match_count
      assert List.first(matches) == expected_first_match
      assert List.last(matches) == expected_last_match
    end
  end
end
