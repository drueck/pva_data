defmodule PVAData.PVAWebsite.ClientBehaviour do
  alias PVAData.{
    Division,
    Match,
    DivisionStanding
  }

  @callback get_teams_by_division(String.t()) :: list(Division.t())
  @callback get_scheduled_matches(String.t()) :: list(Match.t())
  @callback get_completed_matches(String.t()) :: list(Match.t())
  @callback get_division_standings(String.t()) :: list(DivisionStanding.t())
end
