defmodule PVADataWeb.Schema.Query.DivisionsTest do
  use ExUnit.Case
  use Plug.Test

  alias PVAData.{
    Router,
    Data,
    Division
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

  def sort_by_name(maps) do
    Enum.sort_by(maps, & &1.name)
  end
end
