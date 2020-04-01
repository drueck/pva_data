defmodule PVADataWeb.Resolvers.Division do
  alias PVAData.{
    Data,
    Match
  }

  def all(_, _) do
    {:ok, Data.list_divisions()}
  end

  def from_match(%Match{division_id: division_id}, _, _) do
    get(division_id)
  end

  defp get(id) do
    {:ok, Data.get_division(id)}
  end
end
