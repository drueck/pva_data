alias PVAData.{
  Data,
  Team
}

defmodule PVADataWeb.Resolvers.Standing do
  def from_team(%Team{division_id: division_id, id: team_id}, _, _) do
    standing =
      division_id
      |> Data.get_division()
      |> Map.get(:standings)
      |> Enum.find(fn standing -> standing.team_id == team_id end)

    {:ok, standing}
  end
end
