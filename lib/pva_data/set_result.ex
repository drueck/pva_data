defmodule PVAData.SetResult do
  use PVAData.ComputedId, keys: [:match_id, :set_number]

  defstruct [:id, :match_id, :set_number, :home_team_score, :visiting_team_score]
end
