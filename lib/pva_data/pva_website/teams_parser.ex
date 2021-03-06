defmodule PVAData.PVAWebsite.TeamsParser do
  import Meeseeks.CSS

  alias PVAData.{
    Division,
    Team
  }

  def get_teams_by_division(schedules_html) do
    schedules_html
    |> Meeseeks.all(css("select[name=teams] option"))
    |> Enum.reject(&(Meeseeks.attr(&1, "value") == ""))
    |> Enum.map(&Meeseeks.text/1)
    |> Enum.map(&to_team_and_division_map/1)
    |> Enum.group_by(& &1.division, & &1.team)
    |> Enum.map(&build_division_with_teams/1)
    |> Enum.sort_by(& &1.name)
    |> (fn divisions -> {:ok, divisions} end).()
  end

  defp to_team_and_division_map(team_string) do
    ~r/(?<team>.+) \((?<division>.+?)\)/
    |> Regex.named_captures(team_string)
    |> case do
      %{"team" => team, "division" => division} ->
        %{team: team, division: division}

      _ ->
        %{team: team_string, division: "Unknown"}
    end
  end

  defp build_division_with_teams({division_name, team_names}) do
    division =
      Division.new(
        name: division_name,
        slug: Slugger.slugify_downcase(division_name)
      )

    %{division | teams: build_teams(team_names, division.id)}
  end

  defp build_teams(team_names, division_id) do
    team_names
    |> Enum.sort()
    |> Enum.map(fn team_name -> build_team(team_name, division_id) end)
  end

  defp build_team(team_name, division_id) do
    Team.new(
      name: team_name,
      division_id: division_id,
      slug: Slugger.slugify_downcase(team_name)
    )
  end
end
