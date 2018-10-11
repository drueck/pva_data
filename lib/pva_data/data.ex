defmodule PVAData.Data do
  use GenServer

  alias PVAData.Divisions.Division

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{divisions: %{}}}
  end

  def put_division(pid \\ __MODULE__, %Division{} = division) do
    GenServer.cast(pid, {:put_division, division})
  end

  def get_division_names(pid \\ __MODULE__) do
    GenServer.call(pid, :get_division_names)
  end

  def get_division_standings(pid \\ __MODULE__, division_name) do
    GenServer.call(pid, {:get_division_standings, division_name})
  end

  def handle_cast({:put_division, division}, %{divisions: divisions} = state) do
    {:noreply, %{state | divisions: Map.put(divisions, division.name, division)}}
  end

  def handle_call(:get_division_names, _from, %{divisions: divisions} = state) do
    {:reply, Map.keys(divisions), state}
  end

  def handle_call({:get_division_standings, division_name}, _from, state) do
    standings =
      state.divisions
      |> Map.get(division_name)
      |> Map.get(:standings)

    {:reply, standings, state}
  end
end
