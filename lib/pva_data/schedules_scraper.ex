defmodule PVAData.SchedulesScraper do
  import Meeseeks.CSS

  alias PVAData.{
    Match,
    DateUtils
  }

  def get_matches(schedules_html) do
    schedules_html
    |> Meeseeks.all(css("tr.schedule-table__row"))
    |> Enum.map(fn row ->
      [date_string, time_string, home, visitor, location_and_ref, division] =
        row
        |> Meeseeks.all(css("td"))
        |> Enum.map(&Meeseeks.text/1)

      [location, ref] = split_location_and_ref(location_and_ref)
      date = parse_date(date_string)
      time = parse_time(time_string)

      %Match{
        date: date,
        time: time,
        home: home,
        visitor: visitor,
        location: location,
        ref: ref,
        division: division
      }
    end)
    |> (fn matches -> {:ok, matches} end).()
  end

  defp parse_date(date_string) do
    ~r/(?<month>\d{1,2})\/(?<day>\d{1,2})/
    |> Regex.named_captures(date_string)
    |> case do
      nil ->
        nil

      %{"month" => month_string, "day" => day_string} ->
        month = String.to_integer(month_string)
        day = String.to_integer(day_string)
        year = DateUtils.guess_year(month, Date.utc_today())

        case Date.new(year, month, day) do
          {:ok, date} -> date
          _ -> nil
        end
    end
  end

  defp parse_time(time_string) do
    ~r/(?<hour>\d{1,2}):(?<minutes>\d{1,2})/
    |> Regex.named_captures(time_string)
    |> case do
      nil ->
        nil

      %{"hour" => hour_string, "minutes" => minutes_string} ->
        hour = String.to_integer(hour_string) + 12
        minutes = String.to_integer(minutes_string)

        case Time.new(hour, minutes, 0) do
          {:ok, time} -> time
          _ -> nil
        end
    end
  end

  defp split_location_and_ref(location_and_ref) do
    ~r/^(?<location>.*)\((?<ref>.*)\)$/
    |> Regex.named_captures(location_and_ref)
    |> case do
      nil ->
        [location_and_ref, nil]

      %{"location" => location, "ref" => ref} ->
        [String.trim(location), String.trim(ref)]
    end
  end
end
