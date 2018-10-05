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
end
