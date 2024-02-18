defmodule PVAData.MatchTest do
  use ExUnit.Case, async: true

  alias PVAData.{
    Division,
    Team,
    Match,
    SetResult
  }

  describe "add_set_results/2" do
    test "generates set results from the list of scores and adds them to the match" do
      division = Division.build("Coed A Wednesday")
      court_jesters = Team.build(division, "Court Jesters")
      hop_heads = Team.build(division, "Hop Heads")

      match =
        Match.new(
          date: ~D[2021-01-01],
          time: ~T[20:00:00],
          division_id: division.id,
          home_team_id: court_jesters.id,
          visiting_team_id: hop_heads.id
        )

      expected_set_results = [
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 21
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 2,
          home_team_score: 18,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 3,
          home_team_score: 15,
          visiting_team_score: 9
        )
      ]

      match = Match.add_set_results(match, [{25, 21}, {18, 25}, {15, 9}])

      assert match.set_results == expected_set_results
    end
  end

  describe "sets_won/2" do
    test "returns number of sets the given team won in the given match" do
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

      hop_heads =
        Team.new(
          name: "HopHeads",
          slug: "hopheads",
          division_id: division.id
        )

      match =
        Match.new(
          date: ~D[2021-09-22],
          time: ~T[20:00:00],
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: court_jesters.id
        )

      set_results = [
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 18
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 15,
          visiting_team_score: 4
        )
      ]

      match = %{match | set_results: set_results}

      assert Match.sets_won(match, court_jesters) == 1
      assert Match.sets_won(match, hop_heads) == 2
    end
  end

  describe "point_differential/2" do
    test "returns the point differential from the given team's perspective" do
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

      hop_heads =
        Team.new(
          name: "HopHeads",
          slug: "hopheads",
          division_id: division.id
        )

      match =
        Match.new(
          date: ~D[2021-09-22],
          time: ~T[20:00:00],
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: court_jesters.id
        )

      set_results = [
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 18
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 15,
          visiting_team_score: 4
        )
      ]

      match = %{match | set_results: set_results}

      assert Match.point_differential(match, court_jesters) == 25 - 21 + (18 - 25) + (4 - 15)
      assert Match.point_differential(match, hop_heads) == 21 - 25 + (25 - 18) + (15 - 4)
    end
  end

  describe "points_allowed/2" do
    test "returns the total number of points the opponent scored" do
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

      hop_heads =
        Team.new(
          name: "HopHeads",
          slug: "hopheads",
          division_id: division.id
        )

      match =
        Match.new(
          date: ~D[2021-09-22],
          time: ~T[20:00:00],
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: court_jesters.id
        )

      set_results = [
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 18
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 15,
          visiting_team_score: 4
        )
      ]

      match = %{match | set_results: set_results}

      assert Match.points_allowed(match, court_jesters) == 21 + 25 + 15
      assert Match.points_allowed(match, hop_heads) == 25 + 18 + 4
    end
  end

  describe "result/2" do
    test "returns the result from the given team's perspective" do
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

      hop_heads =
        Team.new(
          name: "HopHeads",
          slug: "hopheads",
          division_id: division.id
        )

      match =
        Match.new(
          date: ~D[2021-09-22],
          time: ~T[20:00:00],
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: court_jesters.id
        )

      set_results = [
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 18
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 15,
          visiting_team_score: 4
        )
      ]

      match = %{match | set_results: set_results}

      assert Match.result(match, court_jesters) == :loss
      assert Match.result(match, hop_heads) == :win

      point_differential_results = [
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 18
        )
      ]

      match = %{match | set_results: point_differential_results}

      assert Match.result(match, court_jesters) == :loss
      assert Match.result(match, hop_heads) == :win

      tie_results = [
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 21
        )
      ]

      match = %{match | set_results: tie_results}

      assert Match.result(match, court_jesters) == :tie
      assert Match.result(match, hop_heads) == :tie
    end
  end

  describe "match_points/2" do
    test "it returns the match points earned by the given team" do
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

      hop_heads =
        Team.new(
          name: "HopHeads",
          slug: "hopheads",
          division_id: division.id
        )

      match =
        Match.new(
          date: ~D[2021-09-22],
          time: ~T[20:00:00],
          division_id: division.id,
          home_team_id: hop_heads.id,
          visiting_team_id: court_jesters.id
        )

      set_results = [
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 21,
          visiting_team_score: 25
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 25,
          visiting_team_score: 18
        ),
        SetResult.new(
          match_id: match.id,
          set_number: 1,
          home_team_score: 15,
          visiting_team_score: 4
        )
      ]

      match = %{match | set_results: set_results}

      assert Match.match_points(match, court_jesters) == 0.5
      assert Match.match_points(match, hop_heads) == 4
    end
  end
end
