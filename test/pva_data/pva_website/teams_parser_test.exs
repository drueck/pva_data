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

      expected_first_division =
        Division.new(%{
          name: "Coed A Thursday",
          slug: "coed-a-thursday",
          teams: [
            Team.new(%{division: "Coed A Thursday", name: "Chewblocka", slug: "chewblocka"}),
            Team.new(%{division: "Coed A Thursday", name: "Court Jesters", slug: "court-jesters"}),
            Team.new(%{
              division: "Coed A Thursday",
              name: "Empire Spikes Back",
              slug: "empire-spikes-back"
            }),
            Team.new(%{division: "Coed A Thursday", name: "Group Sets", slug: "group-sets"}),
            Team.new(%{
              division: "Coed A Thursday",
              name: "Other People's Spouses",
              slug: "other-peoples-spouses"
            }),
            Team.new(%{division: "Coed A Thursday", name: "Pokéballs", slug: "pokeballs"}),
            Team.new(%{division: "Coed A Thursday", name: "Pound Town", slug: "pound-town"}),
            Team.new(%{division: "Coed A Thursday", name: "Whatever", slug: "whatever"})
          ]
        })

      assert length(divisions) == expected_division_count
      assert hd(divisions) == expected_first_division
    end
  end
end
