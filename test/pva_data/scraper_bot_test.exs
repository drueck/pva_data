defmodule PVAData.ScraperBotTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Data,
    ScraperBot,
    Division,
    Team,
    Match,
    Standing,
    SetResult
  }

  setup do
    server = start_supervised!({Data, [name: Data]})
    {:ok, server: server}
  end

  describe "#update_data/0" do
    test "updates the data store with the latest info from the website" do
      ScraperBot.update_data()

      assert %{divisions: divisions} = :sys.get_state(Data)
      assert Map.has_key?(divisions, "womens-aa-tuesday")
      assert %Division{} = division = divisions["womens-aa-tuesday"]

      assert division.name == "Womens AA Tuesday"
      assert division.slug == "womens-aa-tuesday"

      assert length(division.teams) == 6
      assert length(division.standings) == 6
      assert length(division.scheduled_matches) == 5
      assert length(division.completed_matches) == 2

      assert %Team{} = hd(division.teams)
      assert %Match{} = hd(division.scheduled_matches)
      assert %Standing{} = hd(division.standings)
      assert %Match{} = completed_match = hd(division.completed_matches)

      assert length(completed_match.set_results) == 3
      assert %SetResult{} = hd(completed_match.set_results)
    end
  end
end
