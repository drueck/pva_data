defmodule PVADataWeb.Schema.Query.DivisionsTest do
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

  test "can get schedules for each division" do
    query = """
    query {
      divisions {
        scheduled_matches {
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
      }
    }
    """

    coed_a_thursday = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")

    court_jesters =
      Team.new(name: "Court Jesters", slug: "court-jesters", division_id: coed_a_thursday.id)

    whatever = Team.new(name: "Whatever", slug: "whatever", division_id: coed_a_thursday.id)

    match_1 =
      Match.new(
        date: ~D[2020-01-01],
        time: ~T[20:00:00],
        division_id: coed_a_thursday.id,
        home_team_id: court_jesters.id,
        visiting_team_id: whatever.id,
        location: "Rex Putnam High School",
        ref: "Marty"
      )

    match_2 =
      Match.new(
        date: ~D[2020-01-07],
        time: ~T[20:00:00],
        division_id: coed_a_thursday.id,
        home_team_id: whatever.id,
        visiting_team_id: court_jesters.id,
        location: "Rex Putnam High School",
        ref: "Marty"
      )

    coed_a_thursday =
      coed_a_thursday
      |> Map.put(:teams, [court_jesters, whatever])
      |> Map.put(:scheduled_matches, [match_1, match_2])

    Data.put_division(coed_a_thursday)

    conn =
      conn(:post, "/api", query: query)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    returned_divisions =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :divisions])

    assert conn.status == 200

    actual_schedules =
      returned_divisions
      |> hd()
      |> Map.get(:scheduled_matches)

    expected_schedules = [
      %{
        id: match_1.id,
        date: "2020-01-01",
        time: "20:00:00",
        division: %{
          id: coed_a_thursday.id,
          name: coed_a_thursday.name,
          slug: coed_a_thursday.slug
        },
        home_team: %{
          id: court_jesters.id,
          name: court_jesters.name,
          slug: court_jesters.slug
        },
        visiting_team: %{
          id: whatever.id,
          name: whatever.name,
          slug: whatever.slug
        },
        location: match_1.location,
        ref: match_1.ref
      },
      %{
        id: match_2.id,
        date: "2020-01-07",
        time: "20:00:00",
        division: %{
          id: coed_a_thursday.id,
          name: coed_a_thursday.name,
          slug: coed_a_thursday.slug
        },
        home_team: %{
          id: whatever.id,
          name: whatever.name,
          slug: whatever.slug
        },
        visiting_team: %{
          id: court_jesters.id,
          name: court_jesters.name,
          slug: court_jesters.slug
        },
        location: match_2.location,
        ref: match_2.ref
      }
    ]

    assert sort_by_id(actual_schedules) == sort_by_id(expected_schedules)
  end

  test "it can get scores for each division" do
    query = """
    query {
      divisions {
        completed_matches {
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
          set_results {
            id
            set_number
            home_team_score
            visiting_team_score
          }
        }
      }
    }
    """

    coed_a_thursday = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")

    court_jesters =
      Team.new(name: "Court Jesters", slug: "court-jesters", division_id: coed_a_thursday.id)

    whatever = Team.new(name: "Whatever", slug: "whatever", division_id: coed_a_thursday.id)

    match_1 =
      Match.new(
        date: ~D[2020-01-01],
        time: ~T[20:00:00],
        division_id: coed_a_thursday.id,
        home_team_id: court_jesters.id,
        visiting_team_id: whatever.id,
        location: "Rex Putnam High School",
        ref: "Marty"
      )

    match_1 =
      match_1
      |> Map.put(:set_results, [
        SetResult.new(
          match_id: match_1.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 23
        ),
        SetResult.new(
          match_id: match_1.id,
          set_number: 2,
          home_team_score: 20,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match_1.id,
          set_number: 3,
          home_team_score: 15,
          visiting_team_score: 7
        )
      ])

    match_2 =
      Match.new(
        date: ~D[2020-01-07],
        time: ~T[20:00:00],
        division_id: coed_a_thursday.id,
        home_team_id: whatever.id,
        visiting_team_id: court_jesters.id,
        location: "Rex Putnam High School",
        ref: "Marty"
      )

    match_2 =
      match_2
      |> Map.put(:set_results, [
        SetResult.new(
          match_id: match_2.id,
          set_number: 1,
          home_team_score: 26,
          visiting_team_score: 24
        ),
        SetResult.new(
          match_id: match_2.id,
          set_number: 2,
          home_team_score: 25,
          visiting_team_score: 7
        ),
        SetResult.new(
          match_id: match_2.id,
          set_number: 2,
          home_team_score: 17,
          visiting_team_score: 15
        )
      ])

    coed_a_thursday =
      coed_a_thursday
      |> Map.put(:teams, [court_jesters, whatever])
      |> Map.put(:completed_matches, [match_1, match_2])

    Data.put_division(coed_a_thursday)

    conn =
      conn(:post, "/api", query: query)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    returned_divisions =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :divisions])

    assert conn.status == 200

    actual_matches =
      returned_divisions
      |> hd()
      |> Map.get(:completed_matches)

    expected_matches = [
      %{
        id: match_1.id,
        date: "2020-01-01",
        time: "20:00:00",
        division: %{
          id: coed_a_thursday.id,
          name: coed_a_thursday.name,
          slug: coed_a_thursday.slug
        },
        home_team: %{
          id: court_jesters.id,
          name: court_jesters.name,
          slug: court_jesters.slug
        },
        visiting_team: %{
          id: whatever.id,
          name: whatever.name,
          slug: whatever.slug
        },
        location: match_1.location,
        ref: match_1.ref,
        set_results:
          match_1.set_results
          |> Enum.map(fn set_result ->
            Map.take(set_result, [:id, :set_number, :home_team_score, :visiting_team_score])
          end)
      },
      %{
        id: match_2.id,
        date: "2020-01-07",
        time: "20:00:00",
        division: %{
          id: coed_a_thursday.id,
          name: coed_a_thursday.name,
          slug: coed_a_thursday.slug
        },
        home_team: %{
          id: whatever.id,
          name: whatever.name,
          slug: whatever.slug
        },
        visiting_team: %{
          id: court_jesters.id,
          name: court_jesters.name,
          slug: court_jesters.slug
        },
        location: match_2.location,
        ref: match_2.ref,
        set_results:
          match_2.set_results
          |> Enum.map(fn set_result ->
            Map.take(set_result, [:id, :set_number, :home_team_score, :visiting_team_score])
          end)
      }
    ]

    assert sort_by_id(actual_matches) == sort_by_id(expected_matches)
  end

  def sort_by_name(maps) do
    Enum.sort_by(maps, & &1.name)
  end

  def sort_by_id(maps) do
    Enum.sort_by(maps, & &1.id)
  end
end
