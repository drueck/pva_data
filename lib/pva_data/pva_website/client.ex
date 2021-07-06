defmodule PVAData.PVAWebsite.Client do
  alias PVAData.PVAWebsite.{
    TeamsParser,
    SchedulesParser,
    ScoresParser,
    StandingsParser
  }

  @behaviour PVAData.PVAWebsite.ClientBehaviour

  def login(password) do
    "https://portlandvolleyball.org/schedules.php"
    |> HTTPoison.post({:form, [{"pass", password}]})
    |> case do
      {:ok, %HTTPoison.Response{status_code: 302, headers: headers}} -> headers
      _ -> []
    end
    |> get_cookies()
  end

  def get_teams_by_division(cookies \\ []) do
    "https://portlandvolleyball.org/schedules.php"
    |> fetch_and_parse(&TeamsParser.get_teams_by_division/1, cookies)
  end

  def get_scheduled_matches(cookies \\ []) do
    "https://portlandvolleyball.org/schedules.php"
    |> fetch_and_parse(&SchedulesParser.get_scheduled_matches/1, cookies)
  end

  def get_completed_matches(cookies \\ []) do
    "https://portlandvolleyball.org/scores.php"
    |> fetch_and_parse(&ScoresParser.get_completed_matches/1, cookies)
  end

  def get_division_standings(cookies \\ []) do
    "https://portlandvolleyball.org/standings.php"
    |> fetch_and_parse(&StandingsParser.get_divisions_standings/1, cookies)
  end

  defp fetch_and_parse(url, parse, cookies) do
    with {:ok, %HTTPoison.Response{body: body}} <-
           HTTPoison.get(url, %{}, hackney: [cookie: [cookies]]) do
      parse.(body)
    end
  end

  defp get_cookies(headers) do
    headers
    |> Enum.find_value(fn
      {"Set-Cookie", cookies} -> cookies
      _ -> nil
    end)
    |> case do
      nil -> {:error, "no cookies found"}
      cookies -> {:ok, cookies}
    end
  end
end
