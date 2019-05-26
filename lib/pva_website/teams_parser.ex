defmodule PVAWebsite.TeamsParser do
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
    %Division{
      name: division_name,
      slug: Slugger.slugify_downcase(division_name),
      teams: build_teams(team_names)
    }
  end

  defp build_teams(team_names) do
    team_names
    |> Enum.sort()
    |> Enum.map(&build_team/1)
  end

  defp build_team(team_name) do
    %Team{
      name: team_name,
      slug: Slugger.slugify_downcase(team_name)
    }
  end
end
