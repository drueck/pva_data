defmodule PVAData.DivisionStandings do
  use PVAData.ComputedId, keys: [:division]

  defstruct [:id, :division, standings: []]
end
