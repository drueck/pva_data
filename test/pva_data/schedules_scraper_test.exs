defmodule PVAData.SchedulesScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    SchedulesScraper,
    Match
  }

  describe "get_matches/1" do
    test "returns a list of matches from the schedules page body" do
      assert {:ok, matches} =
               "test/fixtures/schedules.php"
               |> File.read!()
               |> ShedulesScraper.get_matches()

      expected_match_count = 28

      expected_first_match = %Match{
        date: ~D[2019-04-08],
        time: ~T[19:00:00],
        home: "Ball Busters",
        visitor: "Floor Burn",
        location: "St. Johns Community Center",
        ref: "Jim R.",
        division: "Womens BB"
      }

      expected_last_match = %Match{
        date: ~D[2019-04-10],
        time: ~T[21:00:00],
        home: "Merda Mafia",
        visitor: "Hit it N Dig It",
        location: "East Portland Community Center",
        ref: "Marshall R.",
        division: "Coed A Wednesday"
      }

      matches
      |> Enum.each(fn match -> assert %Match{} = match end)

      assert expected_first_match == Enum.first(matches)
      assert expected_last_match == Enum.last(matches)
    end
  end
end
