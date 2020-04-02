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

  def get_division(pid \\ __MODULE__, id) do
    GenServer.call(pid, {:get_division, id})
  end

  def get_division_by_slug(pid \\ __MODULE__, slug) do
    GenServer.call(pid, {:get_division_by_slug, slug})
  end

  def list_divisions(pid \\ __MODULE__) do
    GenServer.call(pid, :list_divisions)
  end

  def handle_cast({:put_division, division}, %{divisions: divisions} = state) do
    {:noreply, %{state | divisions: Map.put(divisions, division.id, division)}}
  end

  def handle_call({:get_division, id}, _from, %{divisions: divisions} = state) do
    {:reply, Map.get(divisions, id), state}
  end

  def handle_call({:get_division_by_slug, slug}, _from, %{divisions: divisions} = state) do
    division =
      divisions
      |> Map.values()
      |> Enum.find(fn division -> division.slug == slug end)

    {:reply, division, state}
  end

  def handle_call(:list_divisions, _from, %{divisions: divisions} = state) do
    division_list = divisions |> Map.values()

    {:reply, division_list, state}
  end
end
