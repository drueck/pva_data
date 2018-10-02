defmodule PVAData.DivisionDataScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    DivisionsScraper,
    DivisionDataScraper,
    Standings.Standing,
    Matches.Match
  }

  describe "get_division_data/1" do
    test "gets the standings, schedules, and scores from the given url" do
      test_division = DivisionsScraper.get_divisions() |> hd()

      assert %{standings: standings, matches: matches} =
               DivisionDataScraper.get_division_data(test_division.url)

      assert length(standings) > 0

      test_team_record = hd(standings)

      assert %Standing{
               team_name: team_name,
               matches_won: matches_won,
               matches_lost: matches_lost,
               matches_back: matches_back,
               games_won: games_won,
               games_lost: games_lost
             } = test_team_record

      assert is_binary(team_name)
      assert is_integer(matches_won)
      assert is_integer(matches_lost)
      assert is_float(matches_back)
      assert is_integer(games_won)
      assert is_integer(games_lost)

      assert length(matches) > 0

      test_match = hd(matches)

      assert %Match{
               date: date,
               time: time,
               location: %Match.Location{
                 name: location,
                 map_url: map_url
               },
               home: %Match.Team{
                 name: home_team_name,
                 games_won: home_team_wins
               },
               visitor: %Match.Team{
                 name: visiting_team_name,
                 games_won: visiting_team_wins
               }
             } = test_match

      assert %Date{} = date
      assert %Time{} = time
      assert is_binary(location)
      assert is_binary(map_url)
      assert "http" <> _ = map_url
      assert is_binary(home_team_name)
      assert is_integer(home_team_wins) or is_nil(home_team_wins)
      assert is_binary(visiting_team_name)
      assert is_integer(visiting_team_wins) or is_nil(visiting_team_wins)
    end
  end
end
