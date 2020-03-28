defmodule PVAData.Standing do
  use PVAData.ComputedId, keys: [:team, :division]

  defstruct [
    :id,
    :team,
    :division,
    wins: 0,
    losses: 0,
    winning_percentage: 0.0,
    match_points: 0.0,
    match_points_possible: 0.0,
    match_point_percentage: 0.0
  ]
end
