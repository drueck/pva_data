defmodule PVAData.Data do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{divisions: %{}}}
  end

  def put_division(pid \\ __MODULE__, division) do
    GenServer.cast(pid, {:put_division, division})
  end

  def get_division(pid \\ __MODULE__, slug) do
    GenServer.call(pid, {:get_division, slug})
  end

  def list_divisions(pid \\ __MODULE__) do
    GenServer.call(pid, :list_divisions)
  end

  def handle_cast({:put_division, division}, %{divisions: divisions} = state) do
    {:noreply, %{state | divisions: Map.put(divisions, division.slug, division)}}
  end

  def handle_call({:get_division, slug}, _from, %{divisions: divisions} = state) do
    {:reply, Map.get(divisions, slug), state}
  end

  def handle_call(:list_divisions, _from, %{divisions: divisions} = state) do
    division_list = divisions |> Map.values()

    {:reply, division_list, state}
  end
end
