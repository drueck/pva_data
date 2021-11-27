defmodule PVAData.TeamTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Division,
    Team
  }

  describe "build/1" do
    test "builds a team from the given division and team name" do
      division = Division.build("Coed A Wednesday")

      expected_team =
        Team.new(
          name: "Court Jesters",
          slug: "court-jesters",
          division_id: division.id
        )

      assert Team.build(division, "Court Jesters") == expected_team
    end
  end
end
