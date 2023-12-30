defmodule PVADataWeb.Schema.Query.TeamTest do
  use ExUnit.Case
  use Plug.Test

  alias PVAData.{
    Router,
    Data,
    Division,
    Team,
    Standing,
    Match,
    SetResult
  }

  alias PVADataWeb.Token

  @opts Router.init([])

  setup do
    server = start_supervised!({Data, [name: Data]})
    {:ok, token, _} = Token.generate_and_sign()
    {:ok, server: server, token: token}
  end

  test "can request a team by division slug and team slug", %{token: token} do
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
      |> put_req_header("authorization", "Bearer " <> token)
      |> Router.call(@opts)

    returned_team =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :team])

    assert conn.status == 200

    assert returned_team == Map.take(court_jesters, [:id, :name, :slug])
  end

  test "can request a team's division", %{token: token} do
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
      |> put_req_header("authorization", "Bearer " <> token)
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

  test "can request a team's record (standing)", %{token: token} do
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
      |> put_req_header("authorization", "Bearer " <> token)
      |> Router.call(@opts)

    returned_team =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
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

  test "can request a team's scheduled and completed matches", %{token: token} do
    query = """
    query($divisionSlug: String!, $teamSlug: String!) {
      team(divisionSlug: $divisionSlug, teamSlug: $teamSlug) {
        id
        scheduled_matches {
          ...MatchFields
        }
        completed_matches {
          ...MatchFields
          set_results {
            id
            set_number
            home_team_score
            visiting_team_score
          }
        }
      }
    }

    fragment MatchFields on Match {
      id
      date
      time
      division {
        id
        name
        slug
      }
      home_team {
        id
        name
        slug
      }
      visiting_team {
        id
        name
        slug
      }
      location
      ref
    }
    """

    division = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")
    team_1 = Team.new(name: "Court Jesters", slug: "court-jesters", division_id: division.id)
    team_2 = Team.new(name: "Whatever", slug: "whatever", division_id: division.id)

    completed_match =
      Match.new(
        date: ~D[2019-12-31],
        time: ~T[20:00:00],
        division_id: division.id,
        home_team_id: team_2.id,
        visiting_team_id: team_1.id,
        location: "Rex Putnam High School",
        ref: "Marty"
      )

    completed_match =
      completed_match
      |> Map.put(
        :set_results,
        [
          SetResult.new(
            match_id: completed_match.id,
            set_number: 1,
            home_team_score: 25,
            visiting_team_score: 23
          ),
          SetResult.new(
            match_id: completed_match.id,
            set_number: 2,
            home_team_score: 23,
            visiting_team_score: 25
          ),
          SetResult.new(
            match_id: completed_match.id,
            set_number: 3,
            home_team_score: 15,
            visiting_team_score: 13
          )
        ]
      )

    scheduled_match =
      Match.new(
        date: ~D[2020-01-01],
        time: ~T[20:00:00],
        division_id: division.id,
        home_team_id: team_1.id,
        visiting_team_id: team_2.id,
        location: "Rex Putnam High School",
        ref: "Marty"
      )

    division =
      division
      |> Map.put(:teams, [team_1, team_2])
      |> Map.put(:completed_matches, [completed_match])
      |> Map.put(:scheduled_matches, [scheduled_match])

    Data.put_division(division)

    variables = %{
      "divisionSlug" => "coed-a-thursday",
      "teamSlug" => "court-jesters"
    }

    conn =
      conn(:post, "/api", query: query, variables: variables)
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> token)
      |> Router.call(@opts)

    returned_team =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :team])

    assert conn.status == 200

    expected_team = %{
      id: team_1.id,
      completed_matches: [
        %{
          id: completed_match.id,
          date: "2019-12-31",
          time: "20:00:00",
          division: Map.take(division, [:id, :name, :slug]),
          home_team: Map.take(team_2, [:id, :name, :slug]),
          visiting_team: Map.take(team_1, [:id, :name, :slug]),
          location: completed_match.location,
          ref: completed_match.ref,
          set_results:
            completed_match.set_results
            |> Enum.map(fn set_result ->
              Map.take(
                set_result,
                [:id, :set_number, :home_team_score, :visiting_team_score]
              )
            end)
        }
      ],
      scheduled_matches: [
        %{
          id: scheduled_match.id,
          date: "2020-01-01",
          time: "20:00:00",
          division: Map.take(division, [:id, :name, :slug]),
          home_team: Map.take(team_1, [:id, :name, :slug]),
          visiting_team: Map.take(team_2, [:id, :name, :slug]),
          location: scheduled_match.location,
          ref: scheduled_match.ref
        }
      ]
    }

    assert returned_team == expected_team
  end

  test "returns nil if division is not found", %{token: token} do
    query = """
    query($divisionSlug: String!, $teamSlug: String!) {
      team(divisionSlug: $divisionSlug, teamSlug: $teamSlug) {
        id
        name
        slug
      }
    }
    """

    variables = %{
      "divisionSlug" => "invalid",
      "teamSlug" => "invalid"
    }

    conn =
      conn(:post, "/api", query: query, variables: variables)
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> token)
      |> Router.call(@opts)

    returned_team =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :team])

    assert returned_team == nil
  end

  test "returns nil if team not found within division", %{token: token} do
    query = """
    query($divisionSlug: String!, $teamSlug: String!) {
      team(divisionSlug: $divisionSlug, teamSlug: $teamSlug) {
        id
        name
        slug
      }
    }
    """

    empty_division = Division.new(name: "Empty", slug: "empty", teams: [])

    Data.put_division(empty_division)

    variables = %{
      "divisionSlug" => "empty",
      "teamSlug" => "invalid"
    }

    conn =
      conn(:post, "/api", query: query, variables: variables)
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> token)
      |> Router.call(@opts)

    returned_team =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :team])

    assert returned_team == nil
  end
end
