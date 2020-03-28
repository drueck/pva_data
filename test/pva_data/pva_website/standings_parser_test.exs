defmodule PVAData.PVAWebsite.StandingsParserTest do
  use ExUnit.Case, async: true

  alias PVAData.PVAWebsite.StandingsParser

  alias PVAData.{
    DivisionStandings,
    Standing
  }

  describe "get_divisions_standings/1" do
    test "returns a list of divisions standings from the standings page body" do
      assert {:ok, division_standings} =
               "test/fixtures/standings.php"
               |> File.read!()
               |> StandingsParser.get_divisions_standings()

      expected_count = 8

      expected_first =
        DivisionStandings.new(%{
          division: "Coed A Thursday",
          standings: [
            Standing.new(%{
              team: "Pound Town",
              division: "Coed A Thursday",
              wins: 0,
              losses: 0,
              winning_percentage: 0.0,
              match_points: 0.0,
              match_points_possible: 0.0,
              match_point_percentage: 0.0
            }),
            Standing.new(%{
              team: "Group Sets",
              division: "Coed A Thursday",
              wins: 0,
              losses: 0,
              winning_percentage: 0.0,
              match_points: 0.0,
              match_points_possible: 0.0,
              match_point_percentage: 0.0
            }),
            Standing.new(%{
              team: "Court Jesters",
              division: "Coed A Thursday",
              wins: 0,
              losses: 0,
              winning_percentage: 0.0,
              match_points: 0.0,
              match_points_possible: 0.0,
              match_point_percentage: 0.0
            }),
            Standing.new(%{
              team: "Other People's Spouses",
              division: "Coed A Thursday",
              wins: 0,
              losses: 0,
              winning_percentage: 0.0,
              match_points: 0.0,
              match_points_possible: 0.0,
              match_point_percentage: 0.0
            }),
            Standing.new(%{
              team: "Chewblocka",
              division: "Coed A Thursday",
              wins: 0,
              losses: 0,
              winning_percentage: 0.0,
              match_points: 0.0,
              match_points_possible: 0.0,
              match_point_percentage: 0.0
            }),
            Standing.new(%{
              team: "Whatever",
              division: "Coed A Thursday",
              wins: 0,
              losses: 0,
              winning_percentage: 0.0,
              match_points: 0.0,
              match_points_possible: 0.0,
              match_point_percentage: 0.0
            }),
            Standing.new(%{
              team: "Pokéballs",
              division: "Coed A Thursday",
              wins: 0,
              losses: 0,
              winning_percentage: 0.0,
              match_points: 0.0,
              match_points_possible: 0.0,
              match_point_percentage: 0.0
            }),
            Standing.new(%{
              team: "Empire Spikes Back",
              division: "Coed A Thursday",
              wins: 0,
              losses: 0,
              winning_percentage: 0.0,
              match_points: 0.0,
              match_points_possible: 0.0,
              match_point_percentage: 0.0
            })
          ]
        })

      assert length(division_standings) == expected_count
      assert List.first(division_standings) == expected_first
    end
  end
end
