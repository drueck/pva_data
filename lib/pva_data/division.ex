defmodule PVAData.Division do
  use PVAData.ComputedId, keys: [:name]

  defstruct [
    :id,
    :name,
    :slug,
    teams: [],
    standings: [],
    scheduled_matches: [],
    completed_matches: []
  ]
end
