use Mix.Config

config :pva_data,
  pva_website_client: PVAData.PVAWebsite.FakeClient,
  other_children: []
