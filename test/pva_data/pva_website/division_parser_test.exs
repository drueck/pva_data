defmodule PVAData.PVAWebsite.DivisionParserTest do
  use ExUnit.Case, async: true

  alias PVAData.Match
  alias PVAData.PVAWebsite.DivisionParser

  alias PVAData.{Division, Team}

  describe "get_division/1" do
    test "correctly parses a division" do
      assert {:ok, division} =
               "test/fixtures/default/sites/PortlandVolleyball/schedule/597503/Wednesday-Coed-A"
               |> File.read!()
               |> DivisionParser.get_division()

      assert division.name == "Wednesday Coed A"
      assert division.slug == "wednesday-coed-a"

      d = Division.build("Wednesday Coed A")

      dig_deep = %{Team.build(d, "Dig Deep") | contact: "Saechin"}
      ops = %{Team.build(d, "Other People's Spouses") | contact: "Whytock"}
      gangsta = %{Team.build(d, "Gangsta Pair A Dice") | contact: "Crooks"}
      five_squared = %{Team.build(d, "five squared") | contact: "Ralley"}
      back_at_it = %{Team.build(d, "Back At It") | contact: "Rueck"}
      big_digs = %{Team.build(d, "Big Digs") | contact: "Ortiz"}
      giggles = %{Team.build(d, "Hits & Giggles") | contact: "Beltran"}

      expected_teams = [ops, dig_deep, gangsta, back_at_it, big_digs, five_squared, giggles]

      expected_team_data =
        expected_teams
        |> Enum.with_index()
        |> Enum.map(fn {t, rank} ->
          {t.id, t.name, t.slug, t.contact, rank + 1}
        end)

      actual_team_data =
        division.teams
        |> Enum.sort_by(& &1.rank)
        |> Enum.map(fn t ->
          {t.id, t.name, t.slug, t.contact, t.rank}
        end)

      assert actual_team_data == expected_team_data

      expected_standings_data = [
        {1, "Other People's Spouses", 5, 0, 100.0},
        {2, "Dig Deep", 4, 2, 66.667},
        {3, "Gangsta Pair A Dice", 4, 2, 66.667},
        {4, "Back At It", 3, 2, 60.0},
        {5, "Big Digs", 2, 4, 33.333},
        {6, "five squared", 1, 5, 16.667},
        {7, "Hits & Giggles", 1, 5, 16.667}
      ]

      actual_standings_data =
        division.standings
        |> Enum.sort_by(& &1.rank)
        |> Enum.map(fn s ->
          team = Enum.find(division.teams, &(&1.id == s.team_id))
          {s.rank, team.name, s.wins, s.losses, s.winning_percentage}
        end)

      assert actual_standings_data == expected_standings_data

      assert Enum.count(division.scheduled_matches) == 15

      expected_last_scheduled_match_data = {
        ~D[2025-03-12],
        ~T[21:00:00],
        gangsta.id,
        big_digs.id,
        "PA",
        "https://maps.google.com/maps?li=rwp&q=3990%20NW%201st%20St%2CGresham%2COR%2097030",
        nil
      }

      m = List.last(division.scheduled_matches)

      actual_last_scheduled_match_data = {
        m.date,
        m.time,
        m.home_team_id,
        m.visiting_team_id,
        m.location_name,
        m.location_url,
        m.ref
      }

      assert actual_last_scheduled_match_data == expected_last_scheduled_match_data

      assert Enum.count(division.completed_matches) == 20

      expected_last_completed_match_data = {
        ~D[2025-02-05],
        ~T[21:00:00],
        ops.id,
        giggles.id,
        "PA",
        "https://maps.google.com/maps?li=rwp&q=3990%20NW%201st%20St%2CGresham%2COR%2097030",
        "Karen Strong",
        [{1, 25, 11}, {2, 25, 19}, {3, 15, 8}]
      }

      m = List.last(division.completed_matches)

      actual_last_completed_match_data = {
        m.date,
        m.time,
        m.home_team_id,
        m.visiting_team_id,
        m.location_name,
        m.location_url,
        m.ref,
        m.set_results
        |> Enum.map(fn s -> {s.set_number, s.home_team_score, s.visiting_team_score} end)
      }

      assert actual_last_completed_match_data == expected_last_completed_match_data
    end

    test "ignores matches that have been rescheduled" do
      assert {:ok, division} =
               "test/fixtures/rescheduled/sites/PortlandVolleyball/schedule/597454/Womens-Monday-A"
               |> File.read!()
               |> DivisionParser.get_division()

      assert Enum.count(division.scheduled_matches) == 12

      d = Division.build("Women's Monday A")
      sara_and_others = %{Team.build(d, "Sara and Others") | contact: "Sayre"}

      sara_and_others_scheduled =
        division.scheduled_matches
        |> Enum.filter(fn %Match{home_team_id: a_id, visiting_team_id: b_id} ->
          a_id == sara_and_others.id || b_id == sara_and_others.id
        end)

      assert Enum.count(sara_and_others_scheduled) == 3

      expected_dates_and_times = [
        {~D[2025-02-24], ~T[21:00:00]},
        {~D[2025-03-03], ~T[19:00:00]},
        {~D[2025-03-10], ~T[21:00:00]}
      ]

      actual_dates_and_times =
        sara_and_others_scheduled
        |> Enum.map(fn match -> {match.date, match.time} end)

      assert actual_dates_and_times == expected_dates_and_times
    end

    test "handles forfeits" do
      assert {:ok, division} =
               "test/fixtures/comments-and-forfeits/sites/PortlandVolleyball/schedule/597501/Womens-Monday-B"
               |> File.read!()
               |> DivisionParser.get_division()

      assert Enum.count(division.scheduled_matches) == 4
      assert Enum.count(division.completed_matches) == 28

      d = Division.build("Women's Monday B")
      dig_and_dive = %{Team.build(d, "Dig and Dive") | contact: "Evans"}
      filberts = %{Team.build(d, "Filberts") | contact: "Emmert"}
      floor_burn = %{Team.build(d, "Floor Burn") | contact: "Hopkins"}

      dig_and_dive_forfeits =
        division.completed_matches
        |> Enum.filter(fn %Match{} = match ->
          (match.home_team_id == dig_and_dive.id || match.visiting_team_id == dig_and_dive.id) &&
            match.forfeited_team_id == dig_and_dive.id
        end)

      assert Enum.count(dig_and_dive_forfeits) == 2

      dig_and_dive_forfeits
      |> Enum.each(fn match ->
        assert match.set_results == []
        assert Match.has_results?(match)
      end)

      actual_winner_ids =
        dig_and_dive_forfeits
        |> Enum.map(fn match -> match.visiting_team_id end)
        |> Enum.sort()

      expected_winner_ids =
        [filberts.id, floor_burn.id]
        |> Enum.sort()

      assert actual_winner_ids == expected_winner_ids
    end

    test "includes playoffs" do
      assert {:ok, division} =
               "test/fixtures/playoffs-bracket/sites/PortlandVolleyball/schedule/597503/Wednesday-Coed-A"
               |> File.read!()
               |> DivisionParser.get_division()

      d = Division.build("Wednesday Coed A")
      back_at_it = Team.build(d, "Back At It")
      dig_deep = Team.build(d, "Dig Deep")
      big_digs = Team.build(d, "Big Digs")
      ops = Team.build(d, "Other People's Spouses")

      assert Enum.count(division.completed_matches) == 35
      assert Enum.count(division.scheduled_matches) == 2

      expected_first_match_data = {
        ~D[2025-03-19],
        ~T[19:00:00],
        ops.id,
        big_digs.id,
        "MHS Aux Ct 1",
        "https://maps.google.com/maps?li=rwp&q=2301%20SE%20Willard%20St.%2CMilwaukie%2COR%2097222",
        "Karen Strong"
      }

      expected_last_match_data = {
        ~D[2025-03-19],
        ~T[19:00:00],
        back_at_it.id,
        dig_deep.id,
        "MHS Aux Ct 2",
        "https://maps.google.com/maps?li=rwp&q=2301%20SE%20Willard%20St.%2CMilwaukie%2COR%2097222",
        "Scott Lewis"
      }

      [m1, m2] = division.scheduled_matches

      actual_first_match_data = {
        m1.date,
        m1.time,
        m1.home_team_id,
        m1.visiting_team_id,
        m1.location_name,
        m1.location_url,
        m1.ref
      }

      actual_last_match_data = {
        m2.date,
        m2.time,
        m2.home_team_id,
        m2.visiting_team_id,
        m2.location_name,
        m2.location_url,
        m2.ref
      }

      assert actual_first_match_data == expected_first_match_data
      assert actual_last_match_data == expected_last_match_data
    end
  end
end
