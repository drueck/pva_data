defmodule PVAData.DataTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Data,
    Division,
    Team
  }

  setup do
    %{server: start_supervised!(Data)}
  end

  describe "put_division/2" do
    test "adds the division by its slug to the divisions map", %{server: server} do
      coed_a_thursday = %Division{
        name: "Coed A Thursday",
        slug: "coed-a-thursday",
        teams: [
          %Team{name: "Court Jesters", slug: "court-jesters"}
        ]
      }

      assert :ok = Data.put_division(server, coed_a_thursday)

      assert %{divisions: divisions} = :sys.get_state(server)
      assert divisions["coed-a-thursday"] == coed_a_thursday
    end
  end

  describe "get_division/2" do
    test "gets the division with the given slug", %{server: server} do
      coed_a_thursday = %Division{
        name: "Coed A Thursday",
        slug: "coed-a-thursday"
      }

      assert :ok = Data.put_division(server, coed_a_thursday)

      assert ^coed_a_thursday = Data.get_division(server, "coed-a-thursday")
    end
  end

  describe "list_divisions/1" do
    test "returns the list of division names and slugs", %{server: server} do
      [
        %Division{name: "Coed A Thursday", slug: "coed-a-thursday"},
        %Division{name: "Coed B Wednesday", slug: "coed-b-wednesday"}
      ]
      |> Enum.each(&Data.put_division(server, &1))

      divisions = Data.list_divisions(server)

      assert sort_by_name(divisions) ==
               sort_by_name([
                 %{name: "Coed A Thursday", slug: "coed-a-thursday"},
                 %{name: "Coed B Wednesday", slug: "coed-b-wednesday"}
               ])
    end
  end

  def sort_by_name(maps) do
    Enum.sort_by(maps, & &1.name)
  end
end
