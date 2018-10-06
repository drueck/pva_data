defmodule PVAData.ScraperBotTest do
  use ExUnit.Case, async: true

  alias PVAData.{ScraperBot, Data, Divisions.Division}

  describe "update_data/1" do
    test "scrapes all the divsion data and adds it to Data" do
      assert :ok = ScraperBot.update_data()

      assert %{last_updated_at: %Time{}} = :sys.get_state(ScraperBot)
      assert %{divisions: divisions} = :sys.get_state(Data)

      assert length(Map.keys(divisions)) > 0
      assert %Division{} = divisions |> Map.values() |> hd()
    end
  end
end
