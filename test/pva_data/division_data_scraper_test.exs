defmodule PVAData.DivisionDataScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.{DivisionsScraper, DivisionDataScraper}

  describe "get_division_data/1" do
    test "gets the standings, schedules, and scores from the given url" do
      test_division = DivisionsScraper.get_divisions() |> hd()

      assert %{standings: standings, schedules: schedules} =
               DivisionDataScraper.get_division_data(test_division.url)

      assert length(standings) > 0

      test_team_record = hd(standings)

      assert %{
               name: name,
               matches_won: matches_won,
               matches_lost: matches_lost,
               matches_back: matches_back,
               games_won: games_won,
               games_lost: games_lost
             } = test_team_record

      assert is_binary(name)
      assert is_integer(matches_won)
      assert is_integer(matches_lost)
      assert is_float(matches_back)
      assert is_integer(games_won)
      assert is_integer(games_lost)
    end
  end
end
