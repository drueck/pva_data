defmodule PVAData.DivisionsScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.DivisionsScraper

  describe "get_divisions/0" do
    test "it gets the list of divisions with name and url attributes" do
      divisions = DivisionsScraper.get_divisions()

      assert length(divisions) > 0
      assert %{name: name, url: url} = hd(divisions)

      assert is_binary(name)
      assert is_binary(url)

      assert "http://" <> rest = url
    end
  end
end
