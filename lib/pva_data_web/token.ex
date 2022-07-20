defmodule PVADataWeb.Token do
  use Joken.Config

  @four_months_seconds 120 * 24 * 60 * 60

  @impl Joken.Config
  def token_config, do: default_claims(default_exp: @four_months_seconds)
end
