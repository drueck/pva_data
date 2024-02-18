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

  describe "compare_win_percentage/3" do
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

      {result, _} = Division.compare_win_percentage(division, cjs, pound_town)
      assert result < 0
      {result, _} = Division.compare_win_percentage(division, pound_town, cjs)
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

      assert {0, _} = Division.compare_win_percentage(division, cjs, pound_town)
    end
  end

  describe "compare_match_points_percentage/3" do
    test "compares by match points percentage in standings" do
      division = Division.build("Coed A Wednesday")

      newcomers = Team.build(division, "The Newcomers")
      jump_feet = Team.build(division, "21JumpFeet")

      teams = [newcomers, jump_feet]

      standings = [
        Standing.new(
          team_id: newcomers.id,
          division_id: division.id,
          wins: 5,
          losses: 5,
          winning_percentage: 50.00,
          match_points_percentage: 53.33
        ),
        Standing.new(
          team_id: jump_feet.id,
          division_id: division.id,
          wins: 5,
          losses: 5,
          winning_percentage: 50.00,
          match_points_percentage: 46.67
        )
      ]

      division = %{division | teams: teams, standings: standings}

      {result, _} = Division.compare_match_points_percentage(division, jump_feet, newcomers)
      assert result < 0
      {result, _} = Division.compare_match_points_percentage(division, newcomers, jump_feet)
      assert result > 0

      tied_standings = [
        Standing.new(
          team_id: newcomers.id,
          division_id: division.id,
          wins: 5,
          losses: 5,
          winning_percentage: 50.00,
          match_points_percentage: 53.33
        ),
        Standing.new(
          team_id: jump_feet.id,
          division_id: division.id,
          wins: 5,
          losses: 5,
          winning_percentage: 50.00,
          match_points_percentage: 53.33
        )
      ]

      division = %{division | standings: tied_standings}

      assert {0, _} = Division.compare_match_points_percentage(division, newcomers, jump_feet)
    end
  end

  describe "compare_head_to_head_match_points/3" do
    test "compares teams by their head to head record" do
      division = Division.build("Coed A Wednesday")

      cjs = Team.build(division, "Court Jesters")
      pound_town = Team.build(division, "Pound Town")
      hop_heads = Team.build(division, "HopHeads")

      teams = [cjs, pound_town, hop_heads]

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
          date: ~D[2021-10-06],
          time: ~T[19:00:00],
          division_id: division.id,
          home_team_id: pound_town.id,
          visiting_team_id: cjs.id
        )
        |> Match.add_set_results([{25, 17}, {25, 19}, {15, 10}])

      match_3 =
        Match.new(
          date: ~D[2021-11-03],
          time: ~T[20:00:00],
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: cjs.id
        )
        |> Match.add_set_results([{25, 21}, {18, 25}, {4, 15}])

      completed_matches = [match_1, match_2, match_3]

      division = %{division | teams: teams, completed_matches: completed_matches}

      {result, _} = Division.compare_head_to_head_match_points(division, cjs, pound_town)
      assert result < 0
      {result, _} = Division.compare_head_to_head_match_points(division, pound_town, cjs)
      assert result > 0

      assert {0.0, _} = Division.compare_head_to_head_match_points(division, cjs, hop_heads)
    end
  end

  describe "compare_points_differential/3" do
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

      {result, _} = Division.compare_points_differential(division, cjs, hop_heads)
      assert result > 0
      {result, _} = Division.compare_points_differential(division, hop_heads, cjs)
      assert result < 0

      mirror_image_match =
        match_2
        |> Match.add_set_results([{25, 21}, {18, 25}, {4, 15}])

      mirror_images_matches = [match_1, mirror_image_match]

      division = %{division | completed_matches: mirror_images_matches}

      assert {0, _} = Division.compare_points_differential(division, cjs, hop_heads)
      assert {0, _} = Division.compare_points_differential(division, hop_heads, cjs)
    end
  end

  describe "compare_points_allowed_head_to_head/3" do
    test "compares by points allowed in head to head matches" do
      division = Division.build("Coed A Wednesday")

      cjs = Team.build(division, "Court Jesters")
      hop_heads = Team.build(division, "Hop Heads")

      teams = [cjs, hop_heads]

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

      completed_matches = [match_1, match_2]

      division = %{division | teams: teams, completed_matches: completed_matches}

      {result, _} = Division.compare_points_allowed_head_to_head(division, cjs, hop_heads)
      assert result < 0
      {result, _} = Division.compare_points_allowed_head_to_head(division, hop_heads, cjs)
      assert result > 0

      match_2_mirror =
        match_2
        |> Match.add_set_results([{25, 21}, {18, 25}, {4, 15}])

      mirror_image_matches = [match_1, match_2_mirror]

      division = %{division | completed_matches: mirror_image_matches}

      assert {0, _} = Division.compare_points_allowed_head_to_head(division, cjs, hop_heads)
      assert {0, _} = Division.compare_points_allowed_head_to_head(division, hop_heads, cjs)
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
      {:ok, divisions} = Scraper.scrape("test/fixtures/tie-breaker")

      division = Enum.find(divisions, &(&1.name == "Coed A Wednesday"))

      expected_sorted_names = [
        "Pound Town",
        "HopHeads",
        "Court Jesters",
        "The Newcomers",
        "21JumpFeet",
        "Last Minute Ballers",
        "Spiked Punch",
        "Work In Progress"
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
      {:ok, divisions} = Scraper.scrape("test/fixtures/new-season")

      division =
        Enum.find(divisions, &(&1.name == "Coed A Wednesday"))
        |> Division.add_ranks()

      for team <- division.teams do
        assert team.rank == 1
      end

      for standing <- division.standings do
        assert standing.rank == 1
      end
    end

    test "when there is data, ranks should be added accurately" do
      {:ok, divisions} = Scraper.scrape("test/fixtures/tie-breaker")

      division =
        Enum.find(divisions, &(&1.name == "Coed A Wednesday"))
        |> Division.add_ranks()

      assert [
               %Team{
                 name: "Pound Town",
                 rank: 1,
                 rank_reason: %RankReason{
                   statistic: "win percentage",
                   team_value: 90.0,
                   lower_team_value: 80.0
                 }
               },
               %Team{
                 name: "HopHeads",
                 rank: 2,
                 rank_reason: %RankReason{
                   statistic: "head to head record (points differential)",
                   team_value: 11,
                   lower_team_value: -11
                 }
               },
               %Team{
                 name: "Court Jesters",
                 rank: 3,
                 rank_reason: %RankReason{
                   statistic: "win percentage",
                   team_value: 80.0,
                   lower_team_value: 50.0
                 }
               },
               %Team{
                 name: "The Newcomers",
                 rank: 4,
                 rank_reason: %RankReason{
                   statistic: "percentage of possible match points",
                   team_value: 53.33,
                   lower_team_value: 46.67
                 }
               },
               %Team{
                 name: "21JumpFeet",
                 rank: 5,
                 rank_reason: %RankReason{
                   statistic: "win percentage",
                   team_value: 50.0,
                   lower_team_value: 30.0
                 }
               },
               %Team{
                 name: "Last Minute Ballers",
                 rank: 6,
                 rank_reason: %RankReason{
                   statistic: "win percentage",
                   team_value: 30.0,
                   lower_team_value: 10.0
                 }
               },
               %Team{
                 name: "Spiked Punch",
                 rank: 7,
                 rank_reason: %RankReason{
                   statistic: "percentage of possible match points",
                   team_value: 17.78,
                   lower_team_value: 11.11
                 }
               },
               %Team{name: "Work In Progress", rank: 8, rank_reason: nil}
             ] = division.teams

      assert [
               %Standing{
                 rank: 1,
                 rank_reason: %RankReason{
                   statistic: "win percentage",
                   team_value: 90.0,
                   lower_team_value: 80.0
                 }
               },
               %Standing{
                 rank: 2,
                 rank_reason: %RankReason{
                   statistic: "head to head record (points differential)",
                   team_value: 11,
                   lower_team_value: -11
                 }
               },
               %Standing{
                 rank: 3,
                 rank_reason: %RankReason{
                   statistic: "win percentage",
                   team_value: 80.0,
                   lower_team_value: 50.0
                 }
               },
               %Standing{
                 rank: 4,
                 rank_reason: %RankReason{
                   statistic: "percentage of possible match points",
                   team_value: 53.33,
                   lower_team_value: 46.67
                 }
               },
               %Standing{
                 rank: 5,
                 rank_reason: %RankReason{
                   statistic: "win percentage",
                   team_value: 50.0,
                   lower_team_value: 30.0
                 }
               },
               %Standing{
                 rank: 6,
                 rank_reason: %RankReason{
                   statistic: "win percentage",
                   team_value: 30.0,
                   lower_team_value: 10.0
                 }
               },
               %Standing{
                 rank: 7,
                 rank_reason: %RankReason{
                   statistic: "percentage of possible match points",
                   team_value: 17.78,
                   lower_team_value: 11.11
                 }
               },
               %Standing{rank: 8, rank_reason: nil}
             ] = division.standings
    end
  end
end
