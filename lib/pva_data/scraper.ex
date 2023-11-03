defmodule PVAData.Scraper do
  @pva_website Application.compile_env(:pva_data, :pva_website_client)

  def scrape(base_path \\ nil) do
    with {:ok, cookies} <- login_if_password_required(base_path),
         {:ok, divisions} <- @pva_website.get_teams_by_division(base_path, cookies),
         {:ok, scheduled_matches} <- @pva_website.get_scheduled_matches(base_path, cookies),
         {:ok, completed_matches} <- @pva_website.get_completed_matches(base_path, cookies),
         {:ok, division_standings} <- @pva_website.get_division_standings(base_path, cookies) do
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

  defp login_if_password_required(base_path) do
    if Application.get_env(:pva_data, :password_required) do
      @pva_website.login(Application.get_env(:pva_data, :pva_password), base_path)
    else
      {:ok, []}
    end
  end

  defp add_scheduled_matches(division, all_scheduled_matches) do
    all_scheduled_matches
    |> Enum.filter(&(&1.division_id == division.id))
    |> case do
      nil -> division
      scheduled_matches -> %{division | scheduled_matches: scheduled_matches}
    end
  end

  defp add_completed_matches(division, all_completed_matches) do
    all_completed_matches
    |> Enum.filter(&(&1.division_id == division.id))
    |> case do
      nil -> division
      completed_matches -> %{division | completed_matches: completed_matches}
    end
  end

  defp add_standings(division, all_division_standings) do
    all_division_standings
    |> Enum.find(&(&1.division_id == division.id))
    |> case do
      %{standings: standings} -> %{division | standings: standings}
      _ -> division
    end
  end
end
