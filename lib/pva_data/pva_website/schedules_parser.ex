defmodule PVAData.PVAWebsite.SchedulesParser do
  import Meeseeks.CSS

  alias PVAData.PVAWebsite.DateUtils

  alias PVAData.{
    Division,
    Team,
    Match
  }

  def get_scheduled_matches(schedules_html) do
    schedules_html
    |> Meeseeks.all(css("tr.schedule-table__row"))
    |> Enum.map(fn row ->
      [date_string, time_string, home, visitor, location_and_ref, division_name] =
        row
        |> Meeseeks.all(css("td"))
        |> Enum.map(&Meeseeks.text/1)

      division = Division.new(name: division_name)
      home_team = Team.new(name: home, division_id: division.id)
      visiting_team = Team.new(name: visitor, division_id: division.id)

      [location, ref] = split_location_and_ref(location_and_ref)
      date = DateUtils.parse_date(date_string)
      time = DateUtils.parse_time(time_string)

      Match.new(
        date: date,
        time: time,
        division_id: division.id,
        home_team_id: home_team.id,
        visiting_team_id: visiting_team.id,
        location: location,
        ref: ref
      )
    end)
    |> (fn matches -> {:ok, matches} end).()
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
