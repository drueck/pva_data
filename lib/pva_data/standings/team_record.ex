defmodule PVAData.Standings.TeamRecord do
  defstruct [
    :id,
    team_name: "",
    matches_won: 0,
    matches_lost: 0,
    matches_back: 0,
    games_won: 0,
    games_lost: 0
  ]
end
