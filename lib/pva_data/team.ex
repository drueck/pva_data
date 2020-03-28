defmodule PVAData.Team do
  use PVAData.ComputedId, keys: [:name, :division]

  defstruct [:id, :name, :division, :slug]
end
