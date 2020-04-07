defmodule PVAData.PVAWebsite.ClientBehaviour do
  alias PVAData.{
    Division,
    Match,
    DivisionStanding
  }

  @callback get_teams_by_division() :: list(Division.t())
  @callback get_scheduled_matches() :: list(Match.t())
  @callback get_completed_matches() :: list(Match.t())
  @callback get_division_standings() :: list(DivisionStanding.t())
end
