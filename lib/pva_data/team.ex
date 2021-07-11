defmodule PVAData.Team do
  use PVAData.ComputedId, keys: [:name, :division_id]

  defstruct [:id, :name, :division_id, :slug, rank: 0]
end
