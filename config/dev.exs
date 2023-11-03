import Config

config :pva_data,
  pva_website_client: PVAData.PVAWebsite.FakeClient,
  persistence_client: PVAData.Persistence.Redis,
  persistence_state_key: "dev",
  persistence_state_file: "state.dat"

config :rollbax,
  enabled: :log

import_config "dev.secrets.exs"
