defmodule PVAData.DataTest do
  use ExUnit.Case, async: true

  alias PVAData.Data
  alias PVAData.Divisions.Division

  setup do
    data = start_supervised!(Data)
    %{data: data}
  end

  describe "update_divisions/2" do
    test "sets the divisions in the state to the given divisions", %{data: data} do
      divisions = [
        %Division{name: "Coed A Thursday", url: "https://example.com/coed-a-thursday"},
        %Division{name: "Womens AA Monday", url: "https://example.com/womens-aa-monday"}
      ]

      assert :ok = Data.update_divisions(data, divisions)
      assert %{divisions: returned_divisions} = :sys.get_state(data)

      divisions
      |> Enum.each(fn division ->
        assert division in returned_divisions
      end)
    end
  end
end
