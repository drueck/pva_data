defmodule PVADataWeb.Schema.Query.TeamTest do
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

  test "can request a team by division slug and team slug" do
    query = """
    query($divisionSlug: String!, $teamSlug: String!) {
      team(divisionSlug: $divisionSlug, teamSlug: $teamSlug) {
        id
        name
        slug
      }
    }
    """

    coed_a_thursday = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")

    court_jesters =
      Team.new(name: "Court Jesters", slug: "court-jesters", division_id: coed_a_thursday.id)

    whatever = Team.new(name: "Whatever", slug: "whatever", division_id: coed_a_thursday.id)

    coed_a_thursday = %{coed_a_thursday | teams: [court_jesters, whatever]}

    coed_a_wednesday = Division.new(name: "Coed A Wednesday", slug: "coed-a-wednesday")

    court_jesters_wednesday =
      Team.new(name: "Court Jesters", slug: "court-jesters", division_id: coed_a_wednesday.id)

    hop_heads = Team.new(name: "Hop Heads", slug: "hop-heads", division_id: coed_a_wednesday.id)

    coed_a_wednesday = %{coed_a_wednesday | teams: [court_jesters_wednesday, hop_heads]}

    Data.put_division(coed_a_thursday)
    Data.put_division(coed_a_wednesday)

    variables = %{
      "divisionSlug" => "coed-a-thursday",
      "teamSlug" => "court-jesters"
    }

    conn =
      conn(:post, "/api", query: query, variables: variables)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    returned_team =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :team])

    assert conn.status == 200

    assert returned_team == Map.take(court_jesters, [:id, :name, :slug])
  end

  test "can request a team's division" do
    query = """
    query($divisionSlug: String!, $teamSlug: String!) {
      team(divisionSlug: $divisionSlug, teamSlug: $teamSlug) {
        id
        division {
          id
          name
          slug
        }
      }
    }
    """

    coed_a_thursday = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")

    court_jesters =
      Team.new(name: "Court Jesters", slug: "court-jesters", division_id: coed_a_thursday.id)

    coed_a_thursday = %{coed_a_thursday | teams: [court_jesters]}

    Data.put_division(coed_a_thursday)

    variables = %{
      "divisionSlug" => "coed-a-thursday",
      "teamSlug" => "court-jesters"
    }

    conn =
      conn(:post, "/api", query: query, variables: variables)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    returned_team =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :team])

    assert conn.status == 200

    expected_team = %{
      id: court_jesters.id,
      division: %{
        id: coed_a_thursday.id,
        name: coed_a_thursday.name,
        slug: coed_a_thursday.slug
      }
    }

    assert returned_team == expected_team
  end

  test "can request a teams record (standing)" do
    query = """
    query($divisionSlug: String!, $teamSlug: String!) {
      team(divisionSlug: $divisionSlug, teamSlug: $teamSlug) {
        id
        name
        slug
        record {
          division {
            id
            name
            slug
          }
          wins
          losses
          match_points
        }
      }
    }
    """

    division = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")
    team = Team.new(name: "Court Jesters", slug: "court-jesters", division_id: division.id)

    team_standing =
      Standing.new(
        team_id: team.id,
        division_id: division.id,
        wins: 5,
        losses: 3,
        match_points: 22.5
      )

    division =
      division
      |> Map.put(:teams, [team])
      |> Map.put(:standings, [team_standing])

    Data.put_division(division)

    variables = %{
      "divisionSlug" => "coed-a-thursday",
      "teamSlug" => "court-jesters"
    }

    conn =
      conn(:post, "/api", query: query, variables: variables)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    returned_team =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> IO.inspect()
      |> get_in([:data, :team])

    assert conn.status == 200

    expected_team = %{
      id: team.id,
      name: team.name,
      slug: team.slug,
      record: %{
        division: %{
          id: division.id,
          name: division.name,
          slug: division.slug
        },
        wins: team_standing.wins,
        losses: team_standing.losses,
        match_points: team_standing.match_points
      }
    }

    assert returned_team == expected_team
  end
end
