defmodule PVAData.DivisionTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Division,
    Team,
    Standing
  }

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
        rhombus.id => 1,
        have_balls_will_travel.id => 2,
        spike_force.id => 3,
        awkward_high_fives.id => 4,
        too_legit_to_hit.id => 5,
        free_agents.id => 6,
        bump_n_grind.id => 7
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
