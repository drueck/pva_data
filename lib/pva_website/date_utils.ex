defmodule PVAWebsite.DateUtils do
  def parse_date(date_string) do
    ~r/(?<month>\d{1,2})\/(?<day>\d{1,2})/
    |> Regex.named_captures(date_string)
    |> case do
      nil ->
        nil

      %{"month" => month_string, "day" => day_string} ->
        month = String.to_integer(month_string)
        day = String.to_integer(day_string)
        year = guess_year(month, Date.utc_today())

        case Date.new(year, month, day) do
          {:ok, date} -> date
          _ -> nil
        end
    end
  end

  def parse_time(time_string) do
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

  def guess_year(referenced_month, today) do
    case referenced_month do
      m when m in 1..2 ->
        if today.month > 10, do: today.year + 1, else: today.year

      m when m in 10..12 ->
        if today.month < 3, do: today.year - 1, else: today.year

      _ ->
        today.year
    end
  end
end
