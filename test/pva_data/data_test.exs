defmodule PVAData.DataTest do
  use ExUnit.Case, async: true

  alias PVAData.Data
  alias PVAData.Divisions.Division
  alias PVAData.Standings.TeamRecord
  alias PVAData.Matches.Match

  setup do
    %{server: start_supervised!(Data)}
  end

  describe "put_division/2" do
    test "it sets or replaces the given division", %{server: server} do
      division = %Division{name: "Test Division", standings: [], matches: []}

      assert :ok = Data.put_division(server, division)

      assert %{divisions: divisions} = :sys.get_state(server)
      assert Map.get(divisions, division.name) == division
    end
  end

  describe "get_division_names/1" do
    test "it a list of all the division names it knows about", %{server: server} do
      division1 = %Division{name: "Coed A Thursday"}
      division2 = %Division{name: "Coed A Wednesday"}

      assert :ok = Data.put_division(server, division1)
      assert :ok = Data.put_division(server, division2)

      division_names = Data.get_division_names(server)

      assert length(division_names) == 2
      assert division1.name in division_names
      assert division2.name in division_names
    end
  end

  describe "get_division_standings/2" do
    test "it gets the standings for the given division name", %{server: server} do
      coed_a_thursday = %Division{
        name: "Coed A Thursday",
        standings: [
          %TeamRecord{team_name: "Court Jesters", matches_won: 1, matches_lost: 0},
          %TeamRecord{team_name: "Other Team", matches_won: 0, matches_lost: 1}
        ],
        matches: []
      }

      assert :ok = Data.put_division(server, coed_a_thursday)

      standings = Data.get_division_standings(server, "Coed A Thursday")

      assert standings == coed_a_thursday.standings
    end
  end

  describe "get_team_schedule/3" do
    test "it gets the unplayed matches for the given team in the given division, \
          sorted in chronological order",
         %{server: server} do
      played_match = %Match{
        date: ~D[2018-10-04],
        time: ~T[20:00:00.000],
        location: %Match.Location{
          name: "Beaverton Courts > Court 1",
          map_url: "maps.google.com"
        },
        home: %Match.Team{
          name: "Court Jesters",
          games_won: 2
        },
        visitor: %Match.Team{
          name: "Other Team",
          games_won: 1
        }
      }

      first_future_match = %Match{
        date: ~D[2018-10-11],
        time: ~T[20:00:00.000],
        location: %Match.Location{
          name: "Beaverton Courts > Court 2",
          map_url: "maps.google.com"
        },
        home: %Match.Team{
          name: "Court Jesters",
          games_won: nil
        },
        visitor: %Match.Team{
          name: "Other Team",
          games_won: nil
        }
      }

      second_future_match = %Match{
        date: ~D[2018-10-11],
        time: ~T[21:00:00.000],
        location: %Match.Location{
          name: "Beaverton Courts > Court 3",
          map_url: "maps.google.com"
        },
        home: %Match.Team{
          name: "Other Team",
          games_won: nil
        },
        visitor: %Match.Team{
          name: "Court Jesters",
          games_won: nil
        }
      }

      unrelated_match = %Match{
        date: ~D[2018-10-11],
        time: ~T[21:00:00.000],
        location: %Match.Location{
          name: "Beaverton Courts > Court 1",
          map_url: "maps.google.com"
        },
        home: %Match.Team{
          name: "Other Team",
          games_won: nil
        },
        visitor: %Match.Team{
          name: "Other Other Team",
          games_won: nil
        }
      }

      coed_a_thursday = %Division{
        name: "Coed A Thursday",
        standings: [],
        matches: [
          second_future_match,
          played_match,
          first_future_match,
          unrelated_match
        ]
      }

      assert :ok = Data.put_division(server, coed_a_thursday)

      schedule = Data.get_team_schedule(server, "Coed A Thursday", "Court Jesters")
      assert schedule == [first_future_match, second_future_match]
    end
  end
end
