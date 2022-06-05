defmodule PVADataWeb.Resolvers.Authentication do
  alias PVADataWeb.Token

  def login(%{password: password}, _) do
    expected_password = Application.get_env(:pva_data, :pva_password)

    case password do
      ^expected_password ->
        {:ok, token, _} = Token.generate_and_sign()
        {:ok, %{token: token}}

      _ ->
        {:error, "not authorized"}
    end
  end
end
