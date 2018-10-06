defmodule PVADataWeb.Schema.Types do
  use Absinthe.Schema.Notation

  object :division do
    field :name, :string
  end
end
