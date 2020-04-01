defmodule PVADataWeb.Schema do
  use Absinthe.Schema

  import_types PVADataWeb.Schema.Types

  alias PVADataWeb.Resolvers

  query do
    field :divisions, list_of(:division) do
      resolve &Resolvers.Division.all/2
    end
  end
end
