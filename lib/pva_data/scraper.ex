defmodule PVAData.Scraper do
  @pva_website Application.compile_env(:pva_data, :pva_website_client)

  # TODO handle errors

  def scrape(base_path \\ nil) do
    case @pva_website.get_division_urls(base_path) do
      {:ok, division_urls} ->
        division_urls
        |> Enum.map(fn division_url ->
          case @pva_website.get_division(base_path, division_url) do
            {:ok, division} ->
              division

            {:error, _} ->
              # probably report an error that we couldn't get a division
              # should we just fail in this case also?
              nil
          end
        end)
        |> Enum.reject(&is_nil/1)
        |> then(fn divisions -> {:ok, divisions} end)

      error_tuple ->
        error_tuple
    end
  end
end
