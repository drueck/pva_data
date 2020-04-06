use Mix.Config

# compile time configuration goes here
# see config/releases.exs for runtime config

config :pva_data,
  persistence_client: PVAData.Persistence.Redis,
  persistence_state_key: "prod"
