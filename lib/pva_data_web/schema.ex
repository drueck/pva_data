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

      resolve &Resolvers.Division.by_slug/2
    end

    field :team, :team do
      arg :division_slug, :string
      arg :team_slug, :string

      resolve &Resolvers.Team.by_slugs/2
    end
  end
end
