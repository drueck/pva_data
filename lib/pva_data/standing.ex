defmodule PVAData.Standing do
  use PVAData.ComputedId, keys: [:team_id, :division_id]

  defstruct [
    :id,
    :team_id,
    :division_id,
    :rank_reason,
    wins: 0,
    losses: 0,
    winning_percentage: 0.0,
    match_points: 0.0,
    match_points_possible: 0.0,
    match_points_percentage: 0.0,
    rank: 0
  ]
end
