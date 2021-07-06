defmodule PVADataWeb.Token do
  use Joken.Config

  @one_week_seconds 7 * 24 * 60 * 60

  @impl Joken.Config
  def token_config, do: default_claims(default_exp: @one_week_seconds)
end
