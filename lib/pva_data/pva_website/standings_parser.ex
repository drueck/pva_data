defmodule PVAData.PVAWebsite.StandingsParser do
  import Meeseeks.CSS

  alias PVAData.{
    Standing,
    Division,
    Team
  }

  def get_divisions_standings(standings_html) do
    divisions =
      standings_html
      |> Meeseeks.all(css("h3 a"))
      |> Enum.map(&Meeseeks.text/1)
      |> Enum.map(fn division_name -> Division.new(name: division_name) end)

    divisions_standings =
      standings_html
      |> Meeseeks.all(css("table tbody"))
      |> Enum.zip(divisions)
      |> Enum.map(fn {body, division} ->
        body
        |> Meeseeks.all(css("tr"))
        |> tl()
        |> Enum.map(fn row ->
          [
            team_name,
            wins,
            losses,
            winning_percentage,
            match_points,
            match_points_possible,
            match_point_percentage,
            _
          ] =
            row
            |> Meeseeks.all(css("td"))
            |> Enum.map(&Meeseeks.text/1)

          team = Team.new(name: team_name, division_id: division.id)

          Standing.new(
            team_id: team.id,
            division_id: division.id,
            wins: to_int(wins),
            losses: to_int(losses),
            winning_percentage: to_float(winning_percentage),
            match_points: to_float(match_points),
            match_points_possible: to_float(match_points_possible),
            match_point_percentage: to_float(match_point_percentage)
          )
        end)
      end)

    divisions
    |> Enum.zip(divisions_standings)
    |> Enum.map(fn {division, standings} ->
      %{
        division_id: division.id,
        standings: standings
      }
    end)
    |> (fn divisions_standings -> {:ok, divisions_standings} end).()
  end

  def to_int(str) do
    case Integer.parse(str) do
      {value, _} -> value
      :error -> 0
    end
  end

  def to_float(str) do
    case Float.parse(str) do
      {value, _} -> value
      :error -> 0.0
    end
  end
end
