defmodule PVAData.PVAWebsite.StandingsParserTest do
  use ExUnit.Case, async: true

  alias PVAData.PVAWebsite.StandingsParser

  alias PVAData.{
    Team,
    Division,
    Standing
  }

  describe "get_divisions_standings/1" do
    test "returns a list of divisions standings from the standings page body" do
      assert {:ok, division_standings} =
               "test/fixtures/standings.php"
               |> File.read!()
               |> StandingsParser.get_divisions_standings()

      expected_count = 4

      division_id = Division.new(name: "Coed Grass Quads").id

      expected_first = %{
        division_id: division_id,
        standings: [
          Standing.new(
            team_id: Team.new(name: "Have Balls Will Travel", division_id: division_id).id,
            division_id: division_id,
            wins: 2,
            losses: 0,
            winning_percentage: 100.0,
            match_points: 8.5,
            match_points_possible: 9.0,
            match_points_percentage: 94.44
          ),
          Standing.new(
            team_id: Team.new(name: "Hop Heads", division_id: division_id).id,
            division_id: division_id,
            wins: 2,
            losses: 0,
            winning_percentage: 100.0,
            match_points: 8.5,
            match_points_possible: 9.0,
            match_points_percentage: 94.44
          ),
          Standing.new(
            team_id: Team.new(name: "Rhombus", division_id: division_id).id,
            division_id: division_id,
            wins: 1,
            losses: 1,
            winning_percentage: 50.0,
            match_points: 5.0,
            match_points_possible: 9.0,
            match_points_percentage: 55.56
          ),
          Standing.new(
            team_id: Team.new(name: "Spike Force", division_id: division_id).id,
            division_id: division_id,
            wins: 1,
            losses: 1,
            winning_percentage: 50.0,
            match_points: 5.0,
            match_points_possible: 9.0,
            match_points_percentage: 55.56
          ),
          Standing.new(
            team_id: Team.new(name: "Awkward High Fives", division_id: division_id).id,
            division_id: division_id,
            wins: 1,
            losses: 1,
            winning_percentage: 50.0,
            match_points: 4.5,
            match_points_possible: 9.0,
            match_points_percentage: 50.0
          ),
          Standing.new(
            team_id: Team.new(name: "2Legit2Hit", division_id: division_id).id,
            division_id: division_id,
            wins: 1,
            losses: 1,
            winning_percentage: 50.0,
            match_points: 4.5,
            match_points_possible: 9.0,
            match_points_percentage: 50.0
          ),
          Standing.new(
            team_id: Team.new(name: "Bump n' Grind", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 2,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 9.0,
            match_points_percentage: 0.0
          ),
          Standing.new(
            team_id: Team.new(name: "Free Agents", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 2,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 9.0,
            match_points_percentage: 0.0
          )
        ]
      }

      assert length(division_standings) == expected_count
      assert List.first(division_standings) == expected_first
    end
  end
end
