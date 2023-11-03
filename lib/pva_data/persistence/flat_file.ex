defmodule PVAData.Persistence.FlatFile do
  @behaviour PVAData.Persistence.PersistenceBehaviour

  @state_file Application.compile_env(:pva_data, :persistence_state_file)

  def save_state(state) do
    @state_file
    |> File.write(:erlang.term_to_binary(state))
    |> case do
      :ok ->
        :ok

      _ ->
        raise "Failed to save state to file"
    end
  end

  def read_state do
    @state_file
    |> File.read()
    |> case do
      {:ok, binary} ->
        {:ok, :erlang.binary_to_term(binary)}

      _ ->
        {:error, "no state available"}
    end
  end
end
