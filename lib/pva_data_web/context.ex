defmodule PVADataWeb.Context do
  @behaviour Plug

  alias PVADataWeb.Token

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> authenticated?()
    |> case do
      true -> Absinthe.Plug.assign_context(conn, :authenticated, true)
      _ -> conn
    end
  end

  defp authenticated?(conn) do
    with ["Bearer " <> token] <- Plug.Conn.get_req_header(conn, "authorization"),
         {:ok, _} <- Token.verify_and_validate(token) do
      true
    else
      _ -> false
    end
  end
end
