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

      expected_division = Division.new(name: "Womens AA Tuesday")

      division =
        divisions
        |> Enum.find(fn division ->
          division.name == expected_division.name
        end)

      assert division.name == "Womens AA Tuesday"
      assert division.slug == "womens-aa-tuesday"

      assert length(division.teams) == 6
      assert length(division.standings) == 6
      assert length(division.scheduled_matches) == 5
      assert length(division.completed_matches) == 2

      assert %Team{} = hd(division.teams)
      assert %Match{} = hd(division.scheduled_matches)
      assert %Standing{} = hd(division.standings)
      assert %Match{} = completed_match = hd(division.completed_matches)

      assert length(completed_match.set_results) == 3
      assert %SetResult{} = hd(completed_match.set_results)
    end
  end
end
