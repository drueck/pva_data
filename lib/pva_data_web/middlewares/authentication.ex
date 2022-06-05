defmodule PVADataWeb.Middlewares.Authentication do
  @behaviour Absinthe.Middleware

  def call(%{context: %{authenticated: _}} = res, _), do: res

  def call(res, _) do
    if Application.get_env(:pva_data, :password_required) do
      Absinthe.Resolution.put_result(res, {:error, "not authorized"})
    else
      res
    end
  end
end
