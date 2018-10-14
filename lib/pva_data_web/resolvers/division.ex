defmodule PVADataWeb.Resolvers.Division do
  alias PVAData.Data

  def all(pagination_args, _resolution) do
    Data.get_divisions()
    |> Absinthe.Relay.Connection.from_list(pagination_args)
  end

  def get(%{name: name}, _resolution) do
    {:ok, Data.get_division(name)}
  end
end
