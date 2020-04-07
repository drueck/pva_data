use Mix.Config

config :pva_data,
  port: 9001,
  pva_website_client: PVAData.PVAWebsite.Client

import_config "#{Mix.env()}.exs"
