defmodule PVAData.DataTest do
  use ExUnit.Case, async: true

  alias PVAData.Data
  alias PVAData.Divisions.Division

  setup do
    %{server: start_supervised!(Data)}
  end

  describe "put_division/2" do
    test "it sets or replaces the given division", %{server: server} do
      division = %Division{name: "Test Division", standings: [], matches: []}

      assert :ok = Data.put_division(server, division)

      assert %{divisions: divisions} = :sys.get_state(server)
      assert Map.get(divisions, division.name) == division
    end
  end

  describe "get_division_names/1" do
    test "it a list of all the division names it knows about", %{server: server} do
      division1 = %Division{name: "Coed A Thursday"}
      division2 = %Division{name: "Coed A Wednesday"}

      assert :ok = Data.put_division(server, division1)
      assert :ok = Data.put_division(server, division2)

      division_names = Data.get_division_names(server)

      assert length(division_names) == 2
      assert division1.name in division_names
      assert division2.name in division_names
    end
  end
end
