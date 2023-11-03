import Config

config :pva_data,
  port: 9001,
  pva_website_client: PVAData.PVAWebsite.Client

config :joken,
  default_signer: "secret"

import_config "#{Mix.env()}.exs"
