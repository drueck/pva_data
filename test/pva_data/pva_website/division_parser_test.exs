defmodule PVAData.PVAWebsite.DivisionParserTest do
  use ExUnit.Case, async: true

  alias PVAData.PVAWebsite.DivisionParser

  alias PVAData.{Division, Team}

  describe "get_division/1" do
    test "correctly parses a coed division" do
      assert {:ok, division} =
               "test/fixtures/sites/PortlandVolleyball/schedule/597503/Wednesday-Coed-A"
               |> File.read!()
               |> DivisionParser.get_division()

      assert division.name == "Wednesday Coed A"
      assert division.slug == "wednesday-coed-a"

      d = Division.build("Wednesday Coed A")

      dig_deep = Team.build(d, "Dig Deep")
      ops = Team.build(d, "Other People's Spouses")
      gangsta = Team.build(d, "Gangsta Pair A Dice")
      five_squared = Team.build(d, "five squared")
      back_at_it = Team.build(d, "Back At It")
      big_digs = Team.build(d, "Big Digs")
      giggles = Team.build(d, "Hits & Giggles")

      expected_teams = [ops, gangsta, dig_deep, five_squared, giggles, back_at_it, big_digs]

      expected_team_data =
        expected_teams
        |> Enum.with_index()
        |> Enum.map(fn {t, rank} ->
          {t.id, t.name, t.slug, rank + 1}
        end)

      actual_team_data =
        division.teams
        |> Enum.sort_by(& &1.rank)
        |> Enum.map(fn t ->
          {t.id, t.name, t.slug, t.rank}
        end)

      assert actual_team_data == expected_team_data

      # Note: This ranking doesn't currently match what the website showed at
      # the time I took the snapshot, but it does match what the tie breaker
      # list says it should be, so I'm leaving this as the expected sort order.
      expected_standings_data = [
        {1, "Other People's Spouses", 1, 0, 100.0},
        {2, "Gangsta Pair A Dice", 1, 0, 100.0},
        {3, "Dig Deep", 2, 0, 100.0},
        {4, "five squared", 1, 2, 33.333},
        {5, "Hits & Giggles", 0, 1, 0.0},
        {6, "Back At It", 0, 1, 0.0},
        {7, "Big Digs", 0, 1, 0.0}
      ]

      actual_standings_data =
        division.standings
        |> Enum.sort_by(& &1.rank)
        |> Enum.map(fn s ->
          team = Enum.find(division.teams, &(&1.id == s.team_id))
          {s.rank, team.name, s.wins, s.losses, s.winning_percentage}
        end)

      assert actual_standings_data == expected_standings_data

      assert Enum.count(division.scheduled_matches) == 11

      expected_last_scheduled_match_data = {
        ~D[2025-01-29],
        ~T[20:30:00],
        back_at_it.id,
        giggles.id,
        "PMS Large Ct 2",
        "http://maps.google.com/maps?li=rwp&q=11800%20NE%20Shaver%20St.%2CPortland%2COR%2097220"
      }

      m = List.last(division.scheduled_matches)

      actual_last_scheduled_match_data = {
        m.date,
        m.time,
        m.home_team_id,
        m.visiting_team_id,
        m.location_name,
        m.location_url
      }

      assert actual_last_scheduled_match_data == expected_last_scheduled_match_data

      assert Enum.count(division.completed_matches) == 5

      expected_last_completed_match_data = {
        ~D[2025-01-15],
        ~T[20:30:00],
        five_squared.id,
        back_at_it.id,
        "PMS Large Ct 1",
        "http://maps.google.com/maps?li=rwp&q=11800%20NE%20Shaver%20St.%2CPortland%2COR%2097220",
        [{1, 25, 17}, {2, 28, 26}, {3, 16, 14}]
      }

      m = List.last(division.completed_matches)

      actual_last_completed_match_data = {
        m.date,
        m.time,
        m.home_team_id,
        m.visiting_team_id,
        m.location_name,
        m.location_url,
        m.set_results
        |> Enum.map(fn s -> {s.set_number, s.home_team_score, s.visiting_team_score} end)
      }

      assert actual_last_completed_match_data == expected_last_completed_match_data
    end
  end
end
