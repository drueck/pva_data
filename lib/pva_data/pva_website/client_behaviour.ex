defmodule PVAData.PVAWebsite.ClientBehaviour do
  alias PVAData.{
    Division,
    Match,
    DivisionStanding
  }

  @type password :: String.t()
  @type url :: String.t()
  @type cookies :: list(String.t())

  @callback login(password, url) :: {:ok, cookies} | {:error, String.t()}
  @callback get_teams_by_division(url, cookies) :: list(Division.t())
  @callback get_scheduled_matches(url, cookies) :: list(Match.t())
  @callback get_completed_matches(url, cookies) :: list(Match.t())
  @callback get_division_standings(url, cookies) :: list(DivisionStanding.t())
end
