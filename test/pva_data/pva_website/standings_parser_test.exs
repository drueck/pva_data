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

      expected_count = 8

      division_id = Division.new(name: "Coed A Thursday").id

      expected_first = %{
        division_id: division_id,
        standings: [
          Standing.new(
            team_id: Team.new(name: "Pound Town", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_points_percentage: 0.0
          ),
          Standing.new(
            team_id: Team.new(name: "Group Sets", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_points_percentage: 0.0
          ),
          Standing.new(
            team_id: Team.new(name: "Court Jesters", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_points_percentage: 0.0
          ),
          Standing.new(
            team_id: Team.new(name: "Other People's Spouses", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_points_percentage: 0.0
          ),
          Standing.new(
            team_id: Team.new(name: "Chewblocka", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_points_percentage: 0.0
          ),
          Standing.new(
            team_id: Team.new(name: "Whatever", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_points_percentage: 0.0
          ),
          Standing.new(
            team_id: Team.new(name: "Pokéballs", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_points_percentage: 0.0
          ),
          Standing.new(
            team_id: Team.new(name: "Empire Spikes Back", division_id: division_id).id,
            division_id: division_id,
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_points_percentage: 0.0
          )
        ]
      }

      assert length(division_standings) == expected_count
      assert List.first(division_standings) == expected_first
    end
  end
end
