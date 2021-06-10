defmodule PVAData.TeamsScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.PVAWebsite.TeamsParser

  alias PVAData.{
    Division,
    Team
  }

  describe "get_teams_by_division/1" do
    test "returns a list of divisions with teams in each" do
      assert {:ok, divisions} =
               "test/fixtures/schedules.php"
               |> File.read!()
               |> TeamsParser.get_teams_by_division()

      expected_division_count = 4

      first_division = Division.new(name: "Coed Grass Quads", slug: "coed-grass-quads")

      teams = [
        Team.new(division_id: first_division.id, name: "2Legit2Hit", slug: "2legit2hit"),
        Team.new(
          division_id: first_division.id,
          name: "Awkward High Fives",
          slug: "awkward-high-fives"
        ),
        Team.new(division_id: first_division.id, name: "Bump n' Grind", slug: "bump-n-grind"),
        Team.new(division_id: first_division.id, name: "Free Agents", slug: "free-agents"),
        Team.new(
          division_id: first_division.id,
          name: "Have Balls Will Travel",
          slug: "have-balls-will-travel"
        ),
        Team.new(division_id: first_division.id, name: "Hop Heads", slug: "hop-heads"),
        Team.new(division_id: first_division.id, name: "Rhombus", slug: "rhombus"),
        Team.new(division_id: first_division.id, name: "Spike Force", slug: "spike-force")
      ]

      expected_first_division = %{first_division | teams: teams}

      assert length(divisions) == expected_division_count
      assert hd(divisions) == expected_first_division
    end
  end
end
