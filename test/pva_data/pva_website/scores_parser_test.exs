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
      current_year = Date.utc_today().year

      {:ok, first_match_date} = Date.new(current_year, 4, 8)

      expected_first_match =
        Match.new(%{
          date: first_match_date,
          time: ~T[19:00:00],
          home: "Hot Piece of Ace MON",
          visitor: "Lollipop Girls",
          division: "Womens A1 Monday",
          location: nil,
          ref: nil
        })

      expected_first_match =
        expected_first_match
        |> Map.put(
          :set_results,
          [
            SetResult.new(%{
              match_id: expected_first_match.id,
              set: 1,
              home: 25,
              visitor: 11
            }),
            SetResult.new(%{
              match_id: expected_first_match.id,
              set: 2,
              home: 27,
              visitor: 25
            }),
            SetResult.new(%{
              match_id: expected_first_match.id,
              set: 3,
              home: 15,
              visitor: 11
            })
          ]
        )

      {:ok, last_match_date} = Date.new(current_year, 4, 9)

      expected_last_match =
        Match.new(%{
          date: last_match_date,
          time: ~T[20:00:00],
          home: "Natural Diaster",
          visitor: "Sneaker Wave",
          division: "Womens AA Tuesday",
          location: nil,
          ref: nil,
          set_results: []
        })

      expected_last_match =
        expected_last_match
        |> Map.put(
          :set_results,
          [
            SetResult.new(%{
              match_id: expected_last_match.id,
              set: 1,
              home: 25,
              visitor: 21
            }),
            SetResult.new(%{
              match_id: expected_last_match.id,
              set: 2,
              home: 15,
              visitor: 25
            }),
            SetResult.new(%{
              match_id: expected_last_match.id,
              set: 3,
              home: 15,
              visitor: 11
            })
          ]
        )

      assert length(matches) == expected_match_count
      assert List.first(matches) == expected_first_match
      assert List.last(matches) == expected_last_match
    end
  end
end
