defmodule PVAData.PVAWebsite.DivisionListParser do
  import Meeseeks.CSS

  def get_division_urls(division_list_html) do
    division_list_html
    |> Meeseeks.fetch_all(css("#SchedulesPageLayout .schedulesListView:first-child a"))
    |> case do
      {:ok, links} ->
        urls = Enum.map(links, &Meeseeks.attr(&1, "href"))
        {:ok, urls}

      {:error, _} ->
        {:error, "could not fetch division urls"}
    end
  end
end
