defmodule PVADataWeb.Schema.Query.ScheduledMatchesTest do
  use ExUnit.Case
  use Plug.Test

  alias PVAData.{
    Data,
    Router,
    Division,
    Team,
    Match
  }

  alias PVADataWeb.Token

  @opts Router.init([])

  setup do
    server = start_supervised!({Data, [name: Data]})
    {:ok, token, _} = Token.generate_and_sign()
    {:ok, server: server, token: token}
  end

  test "can request scheduled matches by date", %{token: token} do
    query = """
    query ($date: Date!) {
      scheduled_matches(date: $date) {
        id
      }
    }
    """

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

    Data.put_division(division_one)
    Data.put_division(division_two)

    conn =
      conn(:post, "/api", query: query, variables: %{"date" => "2024-01-01"})
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> token)
      |> Router.call(@opts)

    returned_matches =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :scheduled_matches])
      |> Enum.sort_by(& &1.id)

    expected_matches =
      [match_one, match_three]
      |> Enum.map(&Map.take(&1, [:id]))
      |> Enum.sort_by(& &1.id)

    assert returned_matches == expected_matches
  end
end
