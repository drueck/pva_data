defmodule PVADataWeb.Schema.Query.DivisionTest do
  use ExUnit.Case
  use Plug.Test

  alias PVAData.{
    Data,
    Router,
    Division
  }

  alias PVADataWeb.Token

  @opts Router.init([])

  setup do
    server = start_supervised!({Data, [name: Data]})
    {:ok, server: server}
  end

  test "can request a single division by slug" do
    query = """
    query ($slug: String!) {
      division(slug: $slug) {
        id
        name
      }
    }
    """

    division = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")

    Data.put_division(division)

    {:ok, token, _} = Token.generate_and_sign()

    conn =
      conn(:post, "/api", query: query, variables: %{"slug" => "coed-a-thursday"})
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> token)
      |> Router.call(@opts)

    returned_division =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :division])

    assert conn.status == 200

    expected_division = Map.take(division, [:id, :name])

    assert returned_division == expected_division
  end

  test "returns nil if slug doesn't match any division" do
    query = """
    query ($slug: String!) {
      division(slug: $slug) {
        id
        name
      }
    }
    """

    division = Division.new(name: "Coed A Thursday", slug: "coed-a-thursday")

    Data.put_division(division)

    {:ok, token, _} = Token.generate_and_sign()

    conn =
      conn(:post, "/api", query: query, variables: %{"slug" => "thursday-coed-a"})
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> token)
      |> Router.call(@opts)

    returned_division =
      Poison.decode!(conn.resp_body, %{keys: :atoms!})
      |> get_in([:data, :division])

    assert conn.status == 200
    assert returned_division == nil
  end
end
