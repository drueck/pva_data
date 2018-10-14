defmodule PVADataWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types PVADataWeb.Schema.Types

  alias PVADataWeb.Resolvers

  query do
    connection field :divisions, node_type: :division do
      resolve &Resolvers.Division.all/2
    end

    field :division, :division do
      arg :name, :string

      resolve &Resolvers.Division.get/2
    end
  end
end
