defmodule PVAData.DataTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Data,
    Division,
    Team,
    Match
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

      assert %{divisions: divisions, updated_at: _updated_at} = :sys.get_state(server)

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

  describe "get_scheduled_matches_by_date/2" do
    test "returns all scheduled matches on the given date from any division", %{server: server} do
      division_one = Division.new(name: "Division One", slug: "division-one")
      team_one_a = Team.build(division_one, "A")
      team_one_b = Team.build(division_one, "B")

      match_one =
        Match.new(
          date: ~D[2024-01-01],
          time: ~T[19:00:00],
          division_id: division_one.id,
          home_team_id: team_one_a.id,
          visiting_team_id: team_one_b.id
        )

      match_two =
        Match.new(
          date: ~D[2024-01-07],
          time: ~T[19:00:00],
          division_id: division_one.id,
          home_team_id: team_one_b.id,
          visiting_team_id: team_one_a.id
        )

      division_one =
        division_one
        |> Map.put(:teams, [team_one_a, team_one_b])
        |> Map.put(:scheduled_matches, [match_one, match_two])

      division_two = Division.new(name: "Division Two", slug: "division-two")
      team_two_a = Team.build(division_two, "A")
      team_two_b = Team.build(division_two, "B")

      match_three =
        Match.new(
          date: ~D[2024-01-01],
          time: ~T[20:00:00],
          division_id: division_two.id,
          home_team_id: team_two_a.id,
          visiting_team_id: team_two_b.id
        )

      match_four =
        Match.new(
          date: ~D[2024-01-07],
          time: ~T[20:00:00],
          division_id: division_two.id,
          home_team_id: team_two_b.id,
          visiting_team_id: team_two_a.id
        )

      division_two =
        division_two
        |> Map.put(:teams, [team_two_a, team_two_b])
        |> Map.put(:scheduled_matches, [match_three, match_four])

      Data.put_division(server, division_one)
      Data.put_division(server, division_two)

      week_one_matches = Data.get_scheduled_matches_by_date(server, ~D[2024-01-01])

      assert length(week_one_matches) == 2
      assert match_one in week_one_matches
      assert match_three in week_one_matches

      week_two_matches = Data.get_scheduled_matches_by_date(server, ~D[2024-01-07])

      assert length(week_two_matches) == 2
      assert match_two in week_two_matches
      assert match_four in week_two_matches

      week_three_matches = Data.get_scheduled_matches_by_date(server, ~D[2024-01-14])
      assert week_three_matches == []
    end
  end

  def sort_by_name(maps) do
    Enum.sort_by(maps, & &1.name)
  end
end
