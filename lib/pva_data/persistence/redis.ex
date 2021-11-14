defmodule PVAData.Persistence.Redis do
  @behaviour PVAData.Persistence.PersistenceBehaviour

  @state_key Application.get_env(:pva_data, :persistence_state_key)

  def save_state(state) do
    Redix.command(:redix, ["SET", @state_key, :erlang.term_to_binary(state)])
    |> case do
      {:ok, "OK"} ->
        :ok

      error ->
        Rollbax.report_message(:error, "Failed to save state to redis", %{error: error})
        raise "Failed to save state to redis"
    end
  end

  def read_state do
    Redix.command(:redix, ["GET", @state_key])
    |> case do
      {:ok, nil} ->
        Rollbax.report_message(:warning, "No state was found in redis.", %{state_key: @state_key})
        {:error, "no state available"}

      {:ok, serialized_state} ->
        {:ok, :erlang.binary_to_term(serialized_state)}

      error ->
        Rollbax.report_message(:error, "Failed to read state from redis", %{error: error})
        raise "Failed to read state from redis"
    end
  end
end
