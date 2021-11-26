defmodule PVAData.DivisionTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Division,
    Team,
    Standing,
    Match,
    SetResult
  }

  describe "compare_win_percentage/3" do
    test "compares by win percentage in standings" do
      division =
        Division.new(
          name: "Coed A Wednesday",
          slug: "coed-a-wednesday"
        )

      court_jesters =
        Team.new(
          name: "Court Jesters",
          slug: "court-jesters",
          division_id: division.id
        )

      pound_town =
        Team.new(
          name: "Pound Town",
          slug: "pound-town",
          division_id: division.id
        )

      teams = [court_jesters, pound_town]

      standings = [
        Standing.new(
          team_id: court_jesters.id,
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

      assert Division.compare_win_percentage(division, court_jesters, pound_town) < 0
      assert Division.compare_win_percentage(division, pound_town, court_jesters) > 0

      tied_standings = [
        Standing.new(
          team_id: court_jesters.id,
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

      assert Division.compare_win_percentage(division, court_jesters, pound_town) == 0
    end
  end

  describe "compare_match_points_percentage/3" do
    test "compares by match points percentage in standings" do
      division =
        Division.new(
          name: "Coed A Wednesday",
          slug: "coed-a-wednesday"
        )

      newcomers =
        Team.new(
          name: "The Newcomers",
          slug: "the-newcomers",
          division_id: division.id
        )

      jump_feet =
        Team.new(
          name: "21JumpFeet",
          slug: "21jumpfeet",
          division_id: division.id
        )

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

      assert Division.compare_match_points_percentage(division, jump_feet, newcomers) < 0
      assert Division.compare_match_points_percentage(division, newcomers, jump_feet) > 0

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

      assert Division.compare_match_points_percentage(division, newcomers, jump_feet) == 0
    end
  end

  describe "compare_head_to_head/3" do
    test "compares teams by their head to head record" do
      division =
        Division.new(
          name: "Coed A Wednesday",
          slug: "coed-a-wednesday"
        )

      court_jesters =
        Team.new(
          name: "Court Jesters",
          slug: "court-jesters",
          division_id: division.id
        )

      pound_town =
        Team.new(
          name: "Pound Town",
          slug: "pound-town",
          division_id: division.id
        )

      hop_heads =
        Team.new(
          name: "HopHeads",
          slug: "hopheads",
          division_id: division.id
        )

      teams = [court_jesters, pound_town]

      match_1 =
        Match.new(
          date: Date.new(2021, 9, 22),
          time: Time.new(20, 0, 0),
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: court_jesters.id
        )

      match_1_results = [
        SetResult.new(
          match_id: match_1.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match_1.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 18
        ),
        SetResult.new(
          match_id: match_1.id,
          set_number: 1,
          home_team_score: 15,
          visiting_team_score: 4
        )
      ]

      match_1 = %{match_1 | set_results: match_1_results}

      match_2 =
        Match.new(
          date: Date.new(2021, 10, 6),
          time: Time.new(19, 0, 0),
          division_id: division.id,
          home_team_id: pound_town.id,
          visiting_team_id: court_jesters.id
        )

      match_2_results = [
        SetResult.new(
          match_id: match_2.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 17
        ),
        SetResult.new(
          match_id: match_2.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 19
        ),
        SetResult.new(
          match_id: match_2.id,
          set_number: 1,
          home_team_score: 15,
          visiting_team_score: 10
        )
      ]

      match_2 = %{match_2 | set_results: match_2_results}

      match_3 =
        Match.new(
          date: Date.new(2021, 11, 3),
          time: Time.new(20, 0, 0),
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: court_jesters.id
        )

      match_3_results = [
        SetResult.new(
          match_id: match_1.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match_1.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match_1.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        )
      ]

      match_3 = %{match_3 | set_results: match_3_results}

      completed_matches = [match_1, match_2, match_3]

      division = %{division | teams: teams, completed_matches: completed_matches}

      assert Division.compare_head_to_head(division, court_jesters, pound_town) < 0
      assert Division.compare_head_to_head(division, pound_town, court_jesters) > 0
      assert Division.compare_head_to_head(division, court_jesters, hop_heads) == 0
    end
  end

  describe "add_ranks/2" do
    test "adds ranks to each standing and team" do
      division =
        Division.new(
          name: "Coed Grass Quads",
          slug: "coed-grass-quads"
        )

      hop_heads =
        Team.new(
          name: "Hop Heads",
          slug: "hop-heads",
          division_id: division.id
        )

      rhombus =
        Team.new(
          name: "Rhombus",
          slug: "rhombus",
          division_id: division.id
        )

      have_balls_will_travel =
        Team.new(
          name: "Have Balls Will Travel",
          slug: "have-balls-will-travel",
          division_id: division.id
        )

      spike_force =
        Team.new(
          name: "Spike Force",
          slug: "spike-force",
          division_id: division.id
        )

      awkward_high_fives =
        Team.new(
          name: "Awkward High Fives",
          slug: "awkward-high-fives",
          division_id: division.id
        )

      too_legit_to_hit =
        Team.new(
          name: "2Legit2Hit",
          slug: "2legit2hit",
          division_id: division.id
        )

      free_agents =
        Team.new(
          name: "Free Agents",
          slug: "free-agents",
          division_id: division.id
        )

      bump_n_grind =
        Team.new(
          name: "Bump n' Grind",
          slug: "bump-n-grind",
          division_id: division.id
        )

      teams = [
        hop_heads,
        rhombus,
        have_balls_will_travel,
        spike_force,
        awkward_high_fives,
        too_legit_to_hit,
        free_agents,
        bump_n_grind
      ]

      standings = [
        Standing.new(
          team_id: hop_heads.id,
          division_id: division.id,
          wins: 5,
          losses: 1,
          winning_percentage: 83.33,
          match_points_percentage: 83.33
        ),
        Standing.new(
          team_id: rhombus.id,
          division_id: division.id,
          wins: 5,
          losses: 1,
          winning_percentage: 83.33,
          match_points_percentage: 83.33
        ),
        Standing.new(
          team_id: have_balls_will_travel.id,
          division_id: division.id,
          wins: 5,
          losses: 1,
          winning_percentage: 83.33,
          match_points_percentage: 77.78
        ),
        Standing.new(
          team_id: spike_force.id,
          division_id: division.id,
          wins: 3,
          losses: 3,
          winning_percentage: 50.00,
          match_points_percentage: 53.70
        ),
        Standing.new(
          team_id: awkward_high_fives.id,
          division_id: division.id,
          wins: 3,
          losses: 3,
          winning_percentage: 50.00,
          match_points_percentage: 48.15
        ),
        Standing.new(
          team_id: too_legit_to_hit.id,
          division_id: division.id,
          wins: 2,
          losses: 4,
          winning_percentage: 33.33,
          match_points_percentage: 35.19
        ),
        Standing.new(
          team_id: free_agents.id,
          division_id: division.id,
          wins: 1,
          losses: 5,
          winning_percentage: 16.67,
          match_points_percentage: 16.67
        ),
        Standing.new(
          team_id: bump_n_grind.id,
          division_id: division.id,
          wins: 1,
          losses: 5,
          winning_percentage: 0.00,
          match_points_percentage: 1.85
        )
      ]

      division = %{division | teams: teams, standings: standings}

      division_with_ranks = division |> Division.add_ranks()

      expected_ranks = %{
        hop_heads.id => 1,
        rhombus.id => 2,
        have_balls_will_travel.id => 3,
        spike_force.id => 4,
        awkward_high_fives.id => 5,
        too_legit_to_hit.id => 6,
        free_agents.id => 7,
        bump_n_grind.id => 8
      }

      division_with_ranks.teams
      |> Enum.each(fn %{rank: rank, id: id} ->
        assert rank == Map.get(expected_ranks, id)
      end)

      division_with_ranks.standings
      |> Enum.each(fn %{rank: rank, team_id: id} ->
        assert rank == Map.get(expected_ranks, id)
      end)
    end
  end
end
