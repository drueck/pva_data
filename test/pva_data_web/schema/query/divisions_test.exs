defmodule PVADataWeb.Schema.Query.DivisionsTest do
  use ExUnit.Case
  use Plug.Test

  alias PVAData.{
    Router,
    Data,
    Division,
    Team,
    Standing
  }

  @opts Router.init([])

  setup do
    server = start_supervised!({Data, [name: Data]})
    {:ok, server: server}
  end

  test "can request list of divisions" do
    query = """
    query {
      divisions {
        id
        name
        slug
      }
    }
    """

    coed_a_thursday = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")
    womens_aa_monday = Division.new(name: "Womens AA Monday", slug: "womens-aa-monday")

    [coed_a_thursday, womens_aa_monday]
    |> Enum.each(fn division ->
      Data.put_division(division)
    end)

    conn =
      conn(:post, "/api", query: query)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    returned_divisions =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :divisions])

    assert conn.status == 200

    expected_divisions =
      [coed_a_thursday, womens_aa_monday]
      |> Enum.map(fn division -> Map.take(division, [:id, :name, :slug]) end)

    assert sort_by_name(returned_divisions) == sort_by_name(expected_divisions)
  end

  test "can get the list of teams in each division" do
    query = """
    query {
      divisions {
        id
        teams {
          id
          name
          slug
        }
      }
    }
    """

    division = Division.new(name: "Coed A Thursday")

    court_jesters =
      Team.new(name: "Court Jesters", slug: "court-jesters", division_id: division.id)

    whatever = Team.new(name: "Whatever", slug: "whatever", division_id: division.id)

    division = %{division | teams: [court_jesters, whatever]}

    Data.put_division(division)

    conn =
      conn(:post, "/api", query: query)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    returned_divisions =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :divisions])

    assert conn.status == 200

    actual_teams_data =
      returned_divisions
      |> hd()
      |> Map.get(:teams)

    expected_teams_data =
      division
      |> Map.get(:teams)
      |> Enum.map(fn team -> Map.take(team, [:id, :name, :slug]) end)

    assert sort_by_name(actual_teams_data) == sort_by_name(expected_teams_data)
  end

  test "can get standings for each division" do
    query = """
    query {
      divisions {
        standings {
          id
          team {
            id
            name
            slug
          }
          wins
          losses
        }
      }
    }
    """

    division = Division.new(name: "Coed A Thursday")

    court_jesters =
      Team.new(name: "Court Jesters", slug: "court-jesters", division_id: division.id)

    whatever = Team.new(name: "Whatever", slug: "whatever", division_id: division.id)

    court_jesters_standings =
      Standing.new(
        team_id: court_jesters.id,
        division_id: division.id,
        wins: 2,
        losses: 3
      )

    whatever_standings =
      Standing.new(
        team_id: whatever.id,
        division_id: division.id,
        wins: 3,
        losses: 2
      )

    division =
      division
      |> Map.put(:teams, [court_jesters, whatever])
      |> Map.put(:standings, [court_jesters_standings, whatever_standings])

    Data.put_division(division)

    conn =
      conn(:post, "/api", query: query)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    returned_divisions =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :divisions])

    assert conn.status == 200

    actual_standings =
      returned_divisions
      |> hd()
      |> Map.get(:standings)

    expected_standings = [
      %{
        id: court_jesters_standings.id,
        team: %{
          id: court_jesters.id,
          name: "Court Jesters",
          slug: "court-jesters"
        },
        wins: 2,
        losses: 3
      },
      %{
        id: whatever_standings.id,
        team: %{
          id: whatever.id,
          name: "Whatever",
          slug: "whatever"
        },
        wins: 3,
        losses: 2
      }
    ]

    assert sort_by_id(actual_standings) == sort_by_id(expected_standings)
  end

  def sort_by_name(maps) do
    Enum.sort_by(maps, & &1.name)
  end

  def sort_by_id(maps) do
    Enum.sort_by(maps, & &1.id)
  end
end
