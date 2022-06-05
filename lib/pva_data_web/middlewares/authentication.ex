defmodule PVADataWeb.Middlewares.Authentication do
  @behaviour Absinthe.Middleware

  def call(%{context: %{authenticated: _}} = res, _), do: res
  def call(res, _), do: Absinthe.Resolution.put_result(res, {:error, "not authorized"})
end
