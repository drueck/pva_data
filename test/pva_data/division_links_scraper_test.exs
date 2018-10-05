defmodule PVAData.DivisionLinksScraperTest do
  use ExUnit.Case, async: true

  alias PVAData.DivisionLinksScraper

  describe "get_division_links/0" do
    test "it gets the list of division_links with name and url attributes" do
      division_links = DivisionLinksScraper.get_division_links()

      assert length(division_links) > 0
      assert %{name: name, url: url} = hd(division_links)

      assert is_binary(name)
      assert is_binary(url)

      assert "http://" <> rest = url
    end
  end
end
