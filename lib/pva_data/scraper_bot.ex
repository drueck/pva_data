defmodule PVAData.ScraperBot do
  @moduledoc """
    Scrapes the PVA website on a regular schedule and updates the
    Data with the latest info.

    Updates can be triggered any time with `update_data/1`, but regardless,
    they will happen periodically based on the `@update_interval_ms` config below.
  """

  use GenServer

  @initial_update_delay_ms 10
  @update_interval_ms 60 * 60 * 1000

  alias PVAData.{
    DivisionLinksScraper,
    DivisionDataScraper,
    Data
  }

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    if System.get_env("MIX_ENV") != "test" do
      schedule_first_update()
    end

    {:ok, %{last_updated_at: nil}}
  end

  def update_data(pid \\ __MODULE__) do
    GenServer.call(pid, :update_data, 30000)
  end

  def handle_call(:update_data, _from, _state) do
    do_update_data()
    {:reply, :ok, %{last_updated_at: Time.utc_now()}}
  end

  def handle_info(:time_to_update, _state) do
    do_update_data()
    schedule_next_update()
    {:noreply, %{last_updated_at: Time.utc_now()}}
  end

  def do_update_data() do
    DivisionLinksScraper.get_division_links()
    |> Enum.each(fn division_link ->
      DivisionDataScraper.get_division_data(division_link)
      |> Data.put_division()
    end)
  end

  defp schedule_first_update() do
    Process.send_after(self(), :time_to_update, @initial_update_delay_ms)
  end

  defp schedule_next_update() do
    Process.send_after(self(), :time_to_update, @update_interval_ms)
  end
end
