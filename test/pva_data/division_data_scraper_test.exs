defmodule PVAData.DivisionDataScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    DivisionLinksScraper,
    DivisionDataScraper,
    Standings.TeamRecord,
    Matches.Match,
    Divisions.Division
  }

  describe "get_division_data/1" do
    test "gets the division data from the given division link" do
      test_division_link = DivisionLinksScraper.get_division_links() |> hd()

      assert %Division{name: division_name, standings: standings, matches: matches} =
               DivisionDataScraper.get_division_data(test_division_link)

      assert division_name == test_division_link.name
      assert length(standings) > 0
      assert length(matches) > 0

      standings
      |> Enum.each(fn standing ->
        assert %TeamRecord{
                 team_name: team_name,
                 matches_won: matches_won,
                 matches_lost: matches_lost,
                 matches_back: matches_back,
                 games_won: games_won,
                 games_lost: games_lost
               } = standing

        assert is_binary(team_name)
        assert is_integer(matches_won)
        assert is_integer(matches_lost)
        assert is_float(matches_back)
        assert is_integer(games_won)
        assert is_integer(games_lost)
      end)

      matches
      |> Enum.each(fn match ->
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
               } = match

        assert %Date{} = date
        assert %Time{} = time
        assert is_binary(location)
        assert is_binary(map_url)
        assert "http" <> _ = map_url
        assert is_binary(home_team_name)
        assert is_integer(home_team_wins) or is_nil(home_team_wins)
        assert is_binary(visiting_team_name)
        assert is_integer(visiting_team_wins) or is_nil(visiting_team_wins)

        if !is_nil(home_team_wins) || !is_nil(visiting_team_wins) do
          assert !is_nil(home_team_wins) && !is_nil(visiting_team_wins) &&
                   home_team_wins + visiting_team_wins == 3
        end
      end)
    end
  end
end
