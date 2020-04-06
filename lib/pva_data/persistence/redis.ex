defmodule PVAData.Persistence.Redis do
  @behaviour PVAData.Persistence.PersistenceBehaviour

  @state_key Application.get_env(:pva_data, :persistence_state_key)

  def save_state(state) do
    Redix.command(:redix, ["SET", @state_key, :erlang.term_to_binary(state)])
    |> case do
      {:ok, "OK"} -> :ok
      error -> error
    end
  end

  def read_state do
    Redix.command(:redix, ["GET", @state_key])
    |> case do
      {:ok, nil} -> {:error, "no state available"}
      {:ok, serialized_state} -> {:ok, :erlang.binary_to_term(serialized_state)}
      error -> error
    end
  end
end
