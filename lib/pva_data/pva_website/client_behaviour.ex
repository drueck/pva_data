defmodule PVAData.PVAWebsite.ClientBehaviour do
  alias PVAData.Division

  @type url :: String.t()

  @callback get_division_urls(url) :: {:ok, list(url)} | {:error, String.t()}
  @callback get_division(url, url) :: {:ok, Division.t()} | {:error, String.t()}
end
