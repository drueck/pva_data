defmodule PVAData.StandingsScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    StandingsScraper,
    DivisionStandings,
    Standing
  }

  describe "get_divisions_standings/1" do
    test "returns a list of divisions standings from the standings page body" do
      assert {:ok, division_standings} =
               "test/fixtures/standings.php"
               |> File.read!()
               |> StandingsScraper.get_divisions_standings()

      expected_count = 8

      expected_first = %DivisionStandings{
        division: "Coed A Thursday",
        standings: [
          %Standing{
            team: "Pound Town",
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_point_percentage: 0.0
          },
          %Standing{
            team: "Group Sets",
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_point_percentage: 0.0
          },
          %Standing{
            team: "Court Jesters",
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_point_percentage: 0.0
          },
          %Standing{
            team: "Other People's Spouses",
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_point_percentage: 0.0
          },
          %Standing{
            team: "Chewblocka",
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_point_percentage: 0.0
          },
          %Standing{
            team: "Whatever",
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_point_percentage: 0.0
          },
          %Standing{
            team: "Pokéballs",
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_point_percentage: 0.0
          },
          %Standing{
            team: "Empire Spikes Back",
            wins: 0,
            losses: 0,
            winning_percentage: 0.0,
            match_points: 0.0,
            match_points_possible: 0.0,
            match_point_percentage: 0.0
          }
        ]
      }

      assert length(division_standings) == expected_count
      assert List.first(division_standings) == expected_first
    end
  end
end
