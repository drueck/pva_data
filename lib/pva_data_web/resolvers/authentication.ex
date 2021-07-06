defmodule PVADataWeb.Resolvers.Authentication do
  alias PVADataWeb.Token

  @pva_password Application.get_env(:pva_data, :pva_password)

  def login(%{password: password}, _) do
    case password do
      @pva_password ->
        {:ok, token, _} = Token.generate_and_sign()
        {:ok, %{token: token}}

      _ ->
        {:error, "not authorized"}
    end
  end
end
