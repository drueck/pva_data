defmodule PVAData.DataManager do
  use GenServer

  require Logger

  alias PVAData.{
    Data,
    Scraper
  }

  @initial_update_delay_ms 10
  @update_interval_ms 60 * 60 * 1_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    Data.load_state()
    schedule_initial_update()

    {:ok, %{last_checked_at: nil}}
  end

  def handle_info(:time_to_update, _state) do
    do_update_data()
    schedule_next_update()

    {:noreply, %{last_checked_at: DateTime.utc_now()}}
  end

  defp do_update_data do
    Scraper.scrape()
    |> case do
      {:ok, divisions} ->
        divisions
        |> Enum.each(fn division -> Data.put_division(division) end)

        Data.save_state()

      {:error, message} ->
        Rollbax.report_message(:error, "Scraper returned an error", %{message: message})
        nil
    end
  end

  defp schedule_initial_update do
    delay = Data.get_updated_at() |> initial_update_delay()

    Process.send_after(self(), :time_to_update, delay)
  end

  defp schedule_next_update do
    Process.send_after(self(), :time_to_update, @update_interval_ms)
  end

  def initial_update_delay(%DateTime{} = updated_at) do
    ms_until_next_update =
      updated_at
      |> DateTime.add(@update_interval_ms, :millisecond)
      |> DateTime.diff(DateTime.utc_now(), :millisecond)

    cond do
      ms_until_next_update < @initial_update_delay_ms -> @initial_update_delay_ms
      ms_until_next_update < @update_interval_ms -> ms_until_next_update
      true -> @update_interval_ms
    end
  end

  def initial_update_delay(_), do: @initial_update_delay_ms
end
