defmodule PVAData.RankReason do
  use PVAData.ComputedId, keys: [:team_id, :division_id]

  defstruct [
    :id,
    :division_id,
    :team_id,
    :team_value,
    :lower_team_id,
    :lower_team_value,
    :statistic
  ]
end
