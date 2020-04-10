defmodule PVAData.DataTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Data,
    Division
  }

  setup do
    %{server: start_supervised!(Data)}
  end

  describe "update_divisions/2" do
    test "replaces existing divisions with list of divisions given", %{server: server} do
      old_division = Division.new(name: "Old Division", slug: "old-division")
      same_division = Division.new(name: "Same Division", slug: "same-division")
      new_division = Division.new(name: "New Division", slug: "new-division")

      Data.put_division(server, old_division)
      Data.put_division(server, same_division)

      Data.update_divisions(server, [same_division, new_division])

      assert %{divisions: divisions, updated_at: updated_at} = :sys.get_state(server)

      expected_divisions = %{
        same_division.id => same_division,
        new_division.id => new_division
      }

      assert divisions == expected_divisions
    end
  end

  describe "put_division/2" do
    test "adds the division by its id to the divisions map and updates updated_at", %{
      server: server
    } do
      coed_a_thursday = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")

      assert :ok = Data.put_division(server, coed_a_thursday)

      assert %{divisions: divisions, updated_at: updated_at} = :sys.get_state(server)

      assert divisions[coed_a_thursday.id] == coed_a_thursday

      assert DateTime.diff(updated_at, DateTime.utc_now(), :second) < 2
    end
  end

  describe "get_division/2" do
    test "gets the division with the given id", %{server: server} do
      coed_a_thursday = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")

      assert :ok = Data.put_division(server, coed_a_thursday)

      assert ^coed_a_thursday = Data.get_division(server, coed_a_thursday.id)
    end
  end

  describe "get_division_by_slug/2" do
    test "gets the division with the given slug", %{server: server} do
      coed_b_wednesday = Division.new(name: "Coed B Wednesday", slug: "coed-b-wednesday")

      assert :ok = Data.put_division(server, coed_b_wednesday)

      assert ^coed_b_wednesday = Data.get_division_by_slug(server, "coed-b-wednesday")
    end
  end

  describe "list_divisions/1" do
    test "returns the divisions", %{server: server} do
      coed_a_thursday = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")
      coed_b_wednesday = Division.new(name: "Coed B Wednesday", slug: "coed-b-wednesday")

      [coed_a_thursday, coed_b_wednesday]
      |> Enum.each(&Data.put_division(server, &1))

      divisions = Data.list_divisions(server)

      assert sort_by_name(divisions) == sort_by_name([coed_a_thursday, coed_b_wednesday])
    end
  end

  describe "get_updated_at/1" do
    test "returns the updated_at datetime", %{server: server} do
      division = Division.new(name: "Test")
      Data.put_division(server, division)
      assert %{updated_at: updated_at} = :sys.get_state(server)
      assert updated_at
      assert Data.get_updated_at(server) == updated_at
    end
  end

  def sort_by_name(maps) do
    Enum.sort_by(maps, & &1.name)
  end
end
