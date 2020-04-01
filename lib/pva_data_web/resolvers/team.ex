alias PVAData.Data

defmodule PVADataWeb.Resolvers.Team do
  def get(division_id, team_id) do
    team =
      division_id
      |> Data.get_division()
      |> Map.get(:teams)
      |> Enum.find(fn team -> team.id == team_id end)

    {:ok, team}
  end
end
