defmodule PVAData.Match do
  use PVAData.ComputedId, keys: [:date, :time, :home, :visitor, :division]

  defstruct [:id, :date, :time, :home, :visitor, :location, :ref, :division, set_results: []]
end
