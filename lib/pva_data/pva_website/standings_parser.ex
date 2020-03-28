defmodule PVAData.PVAWebsite.StandingsParser do
  import Meeseeks.CSS

  alias PVAData.{
    DivisionStandings,
    Standing
  }

  def get_divisions_standings(standings_html) do
    divisions =
      standings_html
      |> Meeseeks.all(css("h3 a"))
      |> Enum.map(&Meeseeks.text/1)

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
            team,
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

          %{
            team: team,
            division: division,
            wins: to_int(wins),
            losses: to_int(losses),
            winning_percentage: to_float(winning_percentage),
            match_points: to_float(match_points),
            match_points_possible: to_float(match_points_possible),
            match_point_percentage: to_float(match_point_percentage)
          }
          |> Standing.new()
        end)
      end)

    divisions
    |> Enum.zip(divisions_standings)
    |> Enum.map(fn {division, standings} ->
      %{
        division: division,
        standings: standings
      }
      |> DivisionStandings.new()
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
