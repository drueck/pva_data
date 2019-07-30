defmodule PVADataWeb.Schema.Query.DivisionsTest do
  use ExUnit.Case
  use Plug.Test

  alias PVAData.{
    Router,
    Data
  }

  @opts Router.init([])

  test "can request list of divisions" do
    query = """
      query {
        divisions {
          name
          slug
        }
      }
    """

    [
      %PVAData.Division{
        name: "Coed A Thursday",
        slug: "coed-a-thursday"
      },
      %PVAData.Division{
        name: "Womens AA Monday",
        slug: "womens-aa-monday"
      }
    ]
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

    assert sort_by_name(returned_divisions) ==
             [
               %{name: "Coed A Thursday", slug: "coed-a-thursday"},
               %{name: "Womens AA Monday", slug: "womens-aa-monday"}
             ]
  end

  def sort_by_name(maps) do
    Enum.sort_by(maps, & &1.name)
  end
end
