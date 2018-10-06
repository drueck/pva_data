defmodule PVAData.Router do
  use Plug.Router

  plug :match

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Poison

  plug :dispatch

  forward "/api",
    to: Absinthe.Plug,
    init_opts: [schema: PVADataWeb.Schema]

  forward "/graphiql",
    to: Absinthe.Plug.GraphiQL,
    init_opts: [schema: PVADataWeb.Schema]

  match _ do
    send_resp(conn, 404, "oops")
  end
end
