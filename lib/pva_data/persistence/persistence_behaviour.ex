defmodule PVAData.Persistence.PersistenceBehaviour do
  @callback save_state(Map.t()) :: :ok | {:error, String.t()}
  @callback read_state() :: {:ok, Map.t()} | {:error, String.t()}
end
