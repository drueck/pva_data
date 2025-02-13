defmodule PVAData.ScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Scraper,
    Division,
    Team,
    Match,
    Standing,
    SetResult
  }

  describe "scrape/0" do
    test "returns the latest data from the website by divisions" do
      {:ok, divisions} = Scraper.scrape()

      expected_division = Division.new(name: "Wednesday Coed A")

      division =
        divisions
        |> Enum.find(fn division ->
          division.name == expected_division.name
        end)

      assert division.name == "Wednesday Coed A"
      assert division.slug == "wednesday-coed-a"

      assert length(division.teams) == 7
      assert length(division.standings) == 7
      assert length(division.scheduled_matches) == 15
      assert length(division.completed_matches) == 20

      assert %Team{} = hd(division.teams)
      assert %Match{} = hd(division.scheduled_matches)
      assert %Standing{} = hd(division.standings)
      assert %Match{} = completed_match = hd(division.completed_matches)

      assert length(completed_match.set_results) == 3
      assert %SetResult{} = hd(completed_match.set_results)
    end
  end
end
