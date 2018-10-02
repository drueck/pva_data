defmodule PVAData.Data do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def update_divisions(server \\ __MODULE__, divisions) do
    GenServer.cast(server, {:update_divisions, divisions})
  end

  def handle_cast({:update_divisions, divisions}, state) do
    {:noreply, Map.put(state, :divisions, divisions)}
  end
end
