defmodule PVAData.Persistence.Redis do
  @behaviour PVAData.Persistence.PersistenceBehaviour

  @state_key Application.compile_env(:pva_data, :persistence_state_key)

  def save_state(state) do
    try do
      Redix.command!(:redix, ["SET", @state_key, :erlang.term_to_binary(state)])
      :ok
    rescue
      e ->
        Rollbax.report(:error, e, __STACKTRACE__)
        reraise e, __STACKTRACE__
    end
  end

  def read_state do
    try do
      Redix.command!(:redix, ["GET", @state_key])
      |> case do
        nil ->
          Rollbax.report_message(:warning, "No state was found in redis.", %{
            state_key: @state_key
          })

          {:error, "no state available"}

        serialized_state ->
          {:ok, :erlang.binary_to_term(serialized_state)}
      end
    rescue
      e ->
        Rollbax.report(:error, e, __STACKTRACE__)
        reraise e, __STACKTRACE__
    end
  end
end
