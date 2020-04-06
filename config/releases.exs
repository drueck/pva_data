import Config

config :rollbax,
  access_token: System.fetch_env!("ROLLBAR_PROJECT_ACCESS_TOKEN"),
  environment: "production",
  enable_crash_reports: true
