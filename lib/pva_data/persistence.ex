defmodule PVAData.Persistence do
  @behaviour PVAData.Persistence.PersistenceBehaviour

  @persistence_client Application.compile_env(:pva_data, :persistence_client)

  defdelegate save_state(state), to: @persistence_client
  defdelegate read_state(), to: @persistence_client
end
