defmodule PVAData.Data do
  use GenServer

  alias PVAData.Persistence

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{divisions: %{}, checked_at: nil, updated_at: nil, saved_at: nil}}
  end

  def update_divisions(pid \\ __MODULE__, divisions) do
    GenServer.cast(pid, {:update_divisions, divisions})
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

  def set_checked_at(pid \\ __MODULE__, checked_at \\ DateTime.utc_now()) do
    GenServer.cast(pid, {:set_checked_at, checked_at})
  end

  def get_checked_at(pid \\ __MODULE__) do
    GenServer.call(pid, :get_checked_at)
  end

  def get_updated_at(pid \\ __MODULE__) do
    GenServer.call(pid, :get_updated_at)
  end

  def list_divisions(pid \\ __MODULE__) do
    GenServer.call(pid, :list_divisions)
  end

  def get_scheduled_matches_by_date(pid \\ __MODULE__, date) do
    GenServer.call(pid, {:get_scheduled_matches_by_date, date})
  end

  def save_state(pid \\ __MODULE__) do
    GenServer.cast(pid, :save_state)
  end

  def load_state(pid \\ __MODULE__) do
    GenServer.cast(pid, :load_state)
  end

  def handle_cast({:set_checked_at, checked_at}, state) do
    {:noreply, %{state | checked_at: checked_at}}
  end

  def handle_cast({:update_divisions, divisions}, state) do
    divisions_map =
      divisions
      |> Enum.map(fn division -> {division.id, division} end)
      |> Enum.into(%{})

    new_state =
      state
      |> Map.put(:divisions, divisions_map)
      |> Map.put(:updated_at, DateTime.utc_now())

    {:noreply, new_state}
  end

  def handle_cast({:put_division, division}, %{divisions: divisions} = state) do
    state =
      state
      |> Map.put(:divisions, Map.put(divisions, division.id, division))
      |> Map.put(:updated_at, DateTime.utc_now())

    {:noreply, state}
  end

  def handle_cast(:save_state, state) do
    updated_state = %{state | saved_at: DateTime.utc_now()}

    updated_state
    |> Persistence.save_state()
    |> case do
      :ok -> {:noreply, updated_state}
      _ -> {:noreply, state}
    end
  end

  def handle_cast(:load_state, state) do
    Persistence.read_state()
    |> case do
      {:ok, persisted_state} -> {:noreply, persisted_state}
      _ -> {:noreply, state}
    end
  end

  def handle_call(:get_checked_at, _from, %{checked_at: checked_at} = state) do
    {:reply, checked_at, state}
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
    division_list = divisions |> Map.values() |> Enum.sort_by(& &1.name)

    {:reply, division_list, state}
  end

  def handle_call({:get_scheduled_matches_by_date, date}, _from, %{divisions: divisions} = state) do
    scheduled_matches =
      divisions
      |> Map.values()
      |> Stream.flat_map(& &1.scheduled_matches)
      |> Enum.filter(&(&1.date == date))

    {:reply, scheduled_matches, state}
  end

  def handle_call(:get_updated_at, _from, %{updated_at: updated_at} = state) do
    {:reply, updated_at, state}
  end
end
