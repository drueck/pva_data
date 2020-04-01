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

      expected_division_count = 8

      first_division = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")

      teams = [
        Team.new(division_id: first_division.id, name: "Chewblocka", slug: "chewblocka"),
        Team.new(division_id: first_division.id, name: "Court Jesters", slug: "court-jesters"),
        Team.new(
          division_id: first_division.id,
          name: "Empire Spikes Back",
          slug: "empire-spikes-back"
        ),
        Team.new(division_id: first_division.id, name: "Group Sets", slug: "group-sets"),
        Team.new(
          division_id: first_division.id,
          name: "Other People's Spouses",
          slug: "other-peoples-spouses"
        ),
        Team.new(division_id: first_division.id, name: "Pokéballs", slug: "pokeballs"),
        Team.new(division_id: first_division.id, name: "Pound Town", slug: "pound-town"),
        Team.new(division_id: first_division.id, name: "Whatever", slug: "whatever")
      ]

      expected_first_division = %{first_division | teams: teams}

      assert length(divisions) == expected_division_count
      assert hd(divisions) == expected_first_division
    end
  end
end
