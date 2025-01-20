defmodule PVAData.PVAWebsite.DivisionListParserTest do
  use ExUnit.Case, async: true

  alias PVAData.PVAWebsite.DivisionListParser

  describe "get_division_urls/1" do
    test "returns the expected urls" do
      assert {:ok, urls} =
               "test/fixtures/schedules"
               |> File.read!()
               |> DivisionListParser.get_division_urls()

      expected_urls = [
        "/sites/PortlandVolleyball/schedule/599419/Monday-Womens-A2",
        "/sites/PortlandVolleyball/schedule/597504/Thursday-Coed-B",
        "/sites/PortlandVolleyball/schedule/599420/Thursday-Coed-C",
        "/sites/PortlandVolleyball/schedule/597503/Wednesday-Coed-A",
        "/sites/PortlandVolleyball/schedule/605444/Wednesday-Coed-A-2",
        "/sites/PortlandVolleyball/schedule/597454/Womens-Monday-A",
        "/sites/PortlandVolleyball/schedule/597501/Womens-Monday-B",
        "/sites/PortlandVolleyball/schedule/597502/Womens-Tuesday-A"
      ]

      assert urls == expected_urls
    end
  end
end
