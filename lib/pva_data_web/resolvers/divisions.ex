defmodule PVADataWeb.Resolvers.Divisions do
  alias PVAData.Data

  def all(_, _) do
    {:ok, Data.list_divisions()}
  end
end
