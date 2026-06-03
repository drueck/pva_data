defmodule PVAData.DivisionTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Division,
    Team,
    Standing,
    Match,
    RankReason,
    Scraper
  }

  describe "build/1" do
    test "builds a division given the division name" do
      expected_division = Division.new(name: "Court Jesters", slug: "court-jesters")
      assert Division.build("Court Jesters") == expected_division
    end
  end

  describe "compare_winning_percentage/3" do
    test "compares by win percentage in standings" do
      division = Division.build("Coed A Wednesday")

      cjs = Team.build(division, "Court Jesters")
      pound_town = Team.build(division, "Pound Town")

      teams = [cjs, pound_town]

      standings = [
        Standing.new(
          team_id: cjs.id,
          division_id: division.id,
          wins: 8,
          losses: 2,
          winning_percentage: 80.00,
          match_points_percentage: 77.78
        ),
        Standing.new(
          team_id: pound_town.id,
          division_id: division.id,
          wins: 9,
          losses: 1,
          winning_percentage: 90.00,
          match_points_percentage: 87.78
        )
      ]

      division = %{division | teams: teams, standings: standings}

      {result, _} = Division.compare_winning_percentage(division, cjs, pound_town)
      assert result < 0
      {result, _} = Division.compare_winning_percentage(division, pound_town, cjs)
      assert result > 0

      tied_standings = [
        Standing.new(
          team_id: cjs.id,
          division_id: division.id,
          wins: 8,
          losses: 2,
          winning_percentage: 80.00,
          match_points_percentage: 77.78
        ),
        Standing.new(
          team_id: pound_town.id,
          division_id: division.id,
          wins: 8,
          losses: 2,
          winning_percentage: 80.00,
          match_points_percentage: 77.78
        )
      ]

      division = %{division | standings: tied_standings}

      assert {0, _} = Division.compare_winning_percentage(division, cjs, pound_town)
    end
  end

  describe "compare_total_points_differential/3" do
    test "compares based on point differential for all sets for each team" do
      division = Division.build("Coed A Wednesday")

      cjs = Team.build(division, "Court Jesters")
      hop_heads = Team.build(division, "Hop Heads")
      wip = Team.build(division, "Work In Progress")

      teams = [cjs, hop_heads, wip]

      match_1 =
        Match.new(
          date: ~D[2021-09-22],
          time: ~T[20:00:00],
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: cjs.id
        )
        |> Match.add_set_results([{21, 25}, {25, 18}, {15, 4}])

      match_2 =
        Match.new(
          date: ~D[2021-11-03],
          time: ~T[20:00:00],
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: cjs.id
        )
        |> Match.add_set_results([{25, 21}, {18, 25}, {9, 15}])

      cjs_v_wip =
        Match.new(
          date: ~D[2021-11-03],
          time: ~T[19:00:00],
          division_id: division.id,
          home_team_id: cjs.id,
          visiting_team_id: wip.id
        )
        |> Match.add_set_results([{25, 5}, {25, 20}, {15, 3}])

      fake_hhs_v_wip =
        Match.new(
          date: ~D[2021-10-13],
          time: ~T[19:00:00],
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: wip.id
        )
        |> Match.add_set_results([{25, 23}, {25, 23}, {15, 13}])

      completed_matches = [match_1, match_2, cjs_v_wip, fake_hhs_v_wip]

      division = %{division | teams: teams, completed_matches: completed_matches}

      {result, _} = Division.compare_total_points_differential(division, cjs, hop_heads)
      assert result > 0
      {result, _} = Division.compare_total_points_differential(division, hop_heads, cjs)
      assert result < 0

      mirror_image_match =
        match_2
        |> Match.add_set_results([{25, 21}, {18, 25}, {4, 15}])

      mirror_images_matches = [match_1, mirror_image_match]

      division = %{division | completed_matches: mirror_images_matches}

      assert {0, _} = Division.compare_total_points_differential(division, cjs, hop_heads)
      assert {0, _} = Division.compare_total_points_differential(division, hop_heads, cjs)
    end
  end

  describe "compare_names/3" do
    test "compares team names alphabetically" do
      division = Division.build("Coed A Wednesday")
      court_jesters = Team.build(division, "Court Jesters")
      hop_heads = Team.build(division, "Hop Heads")

      {result, _} = Division.compare_names(division, court_jesters, hop_heads)
      assert result > 0
      {result, _} = Division.compare_names(division, hop_heads, court_jesters)
      assert result < 0
      {result, _} = Division.compare_names(division, court_jesters, court_jesters)
      assert result == 0
    end
  end

  describe "compare_teams/2" do
    test "works" do
      {:ok, divisions} = Scraper.scrape("test/fixtures/tie-breakers")

      division = Enum.find(divisions, &(&1.name == "Wednesday Coed A"))

      expected_sorted_names = [
        "Serve Me Daddy",
        "Other People\xe2\x80\x99s Spouses",
        "Volley Parton",
        "Pound Town",
        "Back At It",
        "Whispers",
        "Whatever 2",
        "Hard Pass",
        "Pancakes For Dinner",
        "26 letters",
        "Spikological Warfare"
      ]

      sorted_names =
        division.teams
        |> Enum.sort(fn a, b -> Division.compare_teams(division, a, b) end)
        |> Enum.map(& &1.name)

      assert sorted_names == expected_sorted_names
    end
  end

  describe "add_ranks/2" do
    test "when nobody has played yet, every team should get rank 1" do
      division = Division.build("Wednesday Coed A")
      teams = Enum.map(["Team A", "Team B", "Team C"], &Team.build(division, &1))
      standings = Enum.map(teams, &Standing.new(team_id: &1.id, division_id: division.id))
      division = %{division | teams: teams, standings: standings} |> Division.add_ranks()

      for team <- division.teams, do: assert team.rank == 1
      for standing <- division.standings, do: assert standing.rank == 1
    end

    test "when there is data, ranks should be added accurately" do
      {:ok, divisions} = Scraper.scrape("test/fixtures/tie-breakers")

      division =
        Enum.find(divisions, &(&1.name == "Wednesday Coed A"))
        |> Division.add_ranks()

      assert [
               %Team{
                 name: "Serve Me Daddy",
                 rank: 1,
                 rank_reason: %RankReason{
                   statistic: "average points differential",
                   team_value: 17.125,
                   lower_team_value: 9.0
                 }
               },
               %Team{
                 name: "Other People\xe2\x80\x99s Spouses",
                 rank: 2,
                 rank_reason: %RankReason{
                   statistic: "average points differential",
                   team_value: 9.0,
                   lower_team_value: 6.25
                 }
               },
               %Team{
                 name: "Volley Parton",
                 rank: 3,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 87.5,
                   lower_team_value: 75.0
                 }
               },
               %Team{
                 name: "Pound Town",
                 rank: 4,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 75.0,
                   lower_team_value: 62.5
                 }
               },
               %Team{
                 name: "Back At It",
                 rank: 5,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 62.5,
                   lower_team_value: 50.0
                 }
               },
               %Team{
                 name: "Whispers",
                 rank: 6,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 50.0,
                   lower_team_value: 37.5
                 }
               },
               %Team{
                 name: "Whatever 2",
                 rank: 7,
                 rank_reason: %RankReason{
                   statistic: "average points differential",
                   team_value: -0.625,
                   lower_team_value: -6.875
                 }
               },
               %Team{
                 name: "Hard Pass",
                 rank: 8,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 37.5,
                   lower_team_value: 12.5
                 }
               },
               %Team{
                 name: "Pancakes For Dinner",
                 rank: 9,
                 rank_reason: %RankReason{
                   statistic: "average points differential",
                   team_value: -3.5,
                   lower_team_value: -25.125
                 }
               },
               %Team{
                 name: "26 letters",
                 rank: 10,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 12.5,
                   lower_team_value: +0.0
                 }
               },
               %Team{name: "Spikological Warfare", rank: 11, rank_reason: nil}
             ] = division.teams

      assert [
               %Standing{
                 rank: 1,
                 rank_reason: %RankReason{
                   statistic: "average points differential",
                   team_value: 17.125,
                   lower_team_value: 9.0
                 }
               },
               %Standing{
                 rank: 2,
                 rank_reason: %RankReason{
                   statistic: "average points differential",
                   team_value: 9.0,
                   lower_team_value: 6.25
                 }
               },
               %Standing{
                 rank: 3,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 87.5,
                   lower_team_value: 75.0
                 }
               },
               %Standing{
                 rank: 4,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 75.0,
                   lower_team_value: 62.5
                 }
               },
               %Standing{
                 rank: 5,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 62.5,
                   lower_team_value: 50.0
                 }
               },
               %Standing{
                 rank: 6,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 50.0,
                   lower_team_value: 37.5
                 }
               },
               %Standing{
                 rank: 7,
                 rank_reason: %RankReason{
                   statistic: "average points differential",
                   team_value: -0.625,
                   lower_team_value: -6.875
                 }
               },
               %Standing{
                 rank: 8,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 37.5,
                   lower_team_value: 12.5
                 }
               },
               %Standing{
                 rank: 9,
                 rank_reason: %RankReason{
                   statistic: "average points differential",
                   team_value: -3.5,
                   lower_team_value: -25.125
                 }
               },
               %Standing{
                 rank: 10,
                 rank_reason: %RankReason{
                   statistic: "winning percentage",
                   team_value: 12.5,
                   lower_team_value: +0.0
                 }
               },
               %Standing{rank: 11, rank_reason: nil}
             ] = Enum.sort_by(division.standings, & &1.rank)
    end
  end
end
