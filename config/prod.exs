use Mix.Config

alias PVAData.Data

config :pva_data,
  other_children: [{Data, [name: Data]}]
