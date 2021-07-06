defmodule PVAData.PVAWebsite.ClientBehaviour do
  alias PVAData.{
    Division,
    Match,
    DivisionStanding
  }

  @callback login(String.t()) :: list(String.t())
  @callback get_teams_by_division(list(String.t())) :: list(Division.t())
  @callback get_scheduled_matches(list(String.t())) :: list(Match.t())
  @callback get_completed_matches(list(String.t())) :: list(Match.t())
  @callback get_division_standings(list(String.t())) :: list(DivisionStanding.t())
end
