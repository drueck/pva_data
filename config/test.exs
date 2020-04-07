use Mix.Config

config :pva_data,
  pva_website_client: PVAData.PVAWebsite.FakeClient,
  persistence_client: PVAData.Persistence.FlatFile,
  persistence_state_file: "./state_test.bin",
  other_children: []

config :absinthe,
  log: false

config :rollbax,
  enabled: false
