defmodule PVAData.SetResult do
  use PVAData.ComputedId, keys: [:match_id, :set]

  defstruct [:id, :match_id, :set, :home, :visitor]
end
