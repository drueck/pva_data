defmodule PVADataWeb.Schema do
  use Absinthe.Schema

  import_types PVADataWeb.Schema.Types

  alias PVADataWeb.Resolvers

  query do
    field :divisions, list_of(:division) do
      resolve &Resolvers.Division.all/2
    end

    field :division, :division do
      arg :slug, :string

      resolve &Resolvers.Division.by_slug/3
    end
  end
end
