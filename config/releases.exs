import Config

alias PVAData.{
  Data,
  DataManager
}

config :pva_data,
  port: String.to_integer(System.fetch_env!("PORT")),
  other_children: [
    {Redix,
     [
       host: System.fetch_env!("REDIS_HOST"),
       port: System.fetch_env!("REDIS_PORT") |> String.to_integer(),
       password: System.fetch_env!("REDIS_PASSWORD"),
       name: :redix
     ]},
    {Data, [name: Data]},
    {DataManager, [name: DataManager]}
  ]

config :rollbax,
  access_token: System.fetch_env!("ROLLBAR_PROJECT_ACCESS_TOKEN"),
  environment: "production",
  enable_crash_reports: true
