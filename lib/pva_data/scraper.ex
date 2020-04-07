defmodule PVAData.Scraper do
  @pva_website Application.get_env(:pva_data, :pva_website_client)

  def scrape do
    with {:ok, divisions} <- @pva_website.get_teams_by_division(),
         {:ok, scheduled_matches} <- @pva_website.get_scheduled_matches(),
         {:ok, completed_matches} <- @pva_website.get_completed_matches(),
         {:ok, division_standings} <- @pva_website.get_division_standings() do
      divisions
      |> Enum.map(fn division ->
        division
        |> add_scheduled_matches(scheduled_matches)
        |> add_completed_matches(completed_matches)
        |> add_standings(division_standings)
      end)
      |> (fn divisions -> {:ok, divisions} end).()
    else
      error -> error
    end
  end

  defp add_scheduled_matches(division, all_scheduled_matches) do
    scheduled_matches =
      all_scheduled_matches
      |> Enum.filter(&(&1.division_id == division.id))

    %{division | scheduled_matches: scheduled_matches}
  end

  defp add_completed_matches(division, all_completed_matches) do
    completed_matches =
      all_completed_matches
      |> Enum.filter(&(&1.division_id == division.id))

    %{division | completed_matches: completed_matches}
  end

  defp add_standings(division, all_division_standings) do
    division_standings =
      all_division_standings
      |> Enum.find(&(&1.division_id == division.id))

    %{division | standings: division_standings.standings}
  end
end
