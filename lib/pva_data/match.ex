defmodule PVAData.Match do
  use PVAData.ComputedId, keys: [:date, :time, :division_id, :home_team_id, :visiting_team_id]

  defstruct [
    :id,
    :date,
    :time,
    :division_id,
    :home_team_id,
    :visiting_team_id,
    :location,
    :court,
    :ref,
    set_results: []
  ]
end
