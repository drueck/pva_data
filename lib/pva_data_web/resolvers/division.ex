defmodule PVADataWeb.Resolvers.Division do
  alias PVAData.{
    Data,
    Team,
    Match,
    Standing,
    RankReason
  }

  def all(_, _) do
    {:ok, Data.list_divisions()}
  end

  def from_match(%Match{division_id: division_id}, _, _) do
    get(division_id)
  end

  def from_team(%Team{division_id: division_id}, _, _) do
    get(division_id)
  end

  def from_standing(%Standing{division_id: division_id}, _, _) do
    get(division_id)
  end

  def from_rank_reason(%RankReason{division_id: division_id}, _, _) do
    get(division_id)
  end

  def by_slug(%{slug: slug}, _) do
    division = Data.get_division_by_slug(slug)

    {:ok, division}
  end

  defp get(id) do
    {:ok, Data.get_division(id)}
  end
end
