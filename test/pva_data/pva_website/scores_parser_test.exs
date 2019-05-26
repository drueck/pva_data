defmodule PVAData.PVAWebsite.ScoresParserTest do
  use ExUnit.Case, async: true

  alias PVAData.PVAWebsite.ScoresParser

  alias PVAData.{
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

      expected_first_match = %Match{
        date: ~D[2019-04-08],
        time: ~T[19:00:00],
        home: "Hot Piece of Ace MON",
        visitor: "Lollipop Girls",
        division: "Womens A1 Monday",
        location: nil,
        ref: nil,
        set_results: [
          %SetResult{
            set: 1,
            home: 25,
            visitor: 11
          },
          %SetResult{
            set: 2,
            home: 27,
            visitor: 25
          },
          %SetResult{
            set: 3,
            home: 15,
            visitor: 11
          }
        ]
      }

      expected_last_match = %Match{
        date: ~D[2019-04-09],
        time: ~T[20:00:00],
        home: "Natural Diaster",
        visitor: "Sneaker Wave",
        division: "Womens AA Tuesday",
        location: nil,
        ref: nil,
        set_results: [
          %SetResult{
            set: 1,
            home: 25,
            visitor: 21
          },
          %SetResult{
            set: 2,
            home: 15,
            visitor: 25
          },
          %SetResult{
            set: 3,
            home: 15,
            visitor: 11
          }
        ]
      }

      assert length(matches) == expected_match_count
      assert List.first(matches) == expected_first_match
      assert List.last(matches) == expected_last_match
    end
  end
end
