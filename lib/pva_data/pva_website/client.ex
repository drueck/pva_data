defmodule PVAData.PVAWebsite.Client do
  alias PVAData.PVAWebsite.{
    DivisionListParser,
    DivisionParser
  }

  @behaviour PVAData.PVAWebsite.ClientBehaviour

  @base_path "https://portlandvolleyball.org"

  def get_division_urls(base_path \\ nil) do
    "#{base_path || @base_path}/schedules"
    |> fetch_and_parse(&DivisionListParser.get_division_urls/1)
  end

  def get_division(base_path \\ nil, division_path) do
    "#{base_path || @base_path}/#{division_path}"
    |> fetch_and_parse(&DivisionParser.get_division/1)
  end

  defp fetch_and_parse(url, parse) do
    HTTPoison.get(url, [], follow_redirect: true)
    |> case do
      {:ok, %HTTPoison.Response{body: body}} ->
        parse.(body)

      {:error, error = %HTTPoison.Error{}} ->
        Rollbax.report_message(:error, "pva website request failed", %{
          url: url,
          message: Exception.message(error)
        })

        {:error, "pva website request failed"}
    end
  end
end
