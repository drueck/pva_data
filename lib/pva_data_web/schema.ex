defmodule PVADataWeb.Schema do
  use Absinthe.Schema

  import_types PVADataWeb.Schema.Types

  alias PVADataWeb.Resolvers

  query do
    field :login, type: :session do
      arg :password, non_null(:string)

      resolve &Resolvers.Authentication.login/2
    end

    field :divisions, list_of(:division) do
      middleware PVADataWeb.Middlewares.Authentication
      resolve &Resolvers.Division.all/2
    end

    field :division, :division do
      middleware PVADataWeb.Middlewares.Authentication
      arg :slug, :string

      resolve &Resolvers.Division.by_slug/2
    end

    field :team, :team do
      middleware PVADataWeb.Middlewares.Authentication
      arg :division_slug, :string
      arg :team_slug, :string

      resolve &Resolvers.Team.by_slugs/2
    end
  end
end
