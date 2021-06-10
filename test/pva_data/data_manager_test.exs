defmodule PVAData.DataManagerTest do
  use ExUnit.Case, async: true

  alias PVAData.DataManager

  describe "initial_update_delay/1" do
    test "when updated_at is nil it returns 10 (milliseconds)" do
      assert DataManager.initial_update_delay(nil) == 10
    end

    test "when updated_at was over 30 minutes ago it returns 10 (milliseconds)" do
      minus_two_hours = 2 * 60 * 60 * -1
      updated_at = DateTime.utc_now() |> DateTime.add(minus_two_hours)

      assert DataManager.initial_update_delay(updated_at) == 10
    end

    test """
    when updated_at was less than 30 minutes ago
    it returns the number of milliseconds between updated_at and now
    """ do
      minus_fifteen_minutes = 15 * 60 * -1
      updated_at = DateTime.utc_now() |> DateTime.add(minus_fifteen_minutes)

      expected_delay = DateTime.diff(DateTime.utc_now(), updated_at, :millisecond)

      assert expected_delay > 0

      assert_in_delta(
        DataManager.initial_update_delay(updated_at),
        expected_delay,
        1000
      )
    end

    test "when updated_at was errantly in the future it returns 30 mins in ms" do
      updated_at = DateTime.utc_now() |> DateTime.add(30)

      thirty_mins_in_ms = 30 * 60 * 1_000

      assert DataManager.initial_update_delay(updated_at) == thirty_mins_in_ms
    end
  end
end
