defmodule PVAData.DivisionsScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.DivisionsScraper

  describe "get_divisions/0" do
    test "it gets the list of divisions with name and url attributes" do
      divisions = DivisionsScraper.get_divisions()

      assert length(divisions) > 0
      assert %{name: _, url: _} = hd(divisions)
    end
  end
end
