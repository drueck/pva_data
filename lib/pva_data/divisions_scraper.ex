defmodule PVAData.DivisionsScraper do
  import Meeseeks.CSS

  alias PVAData.Divisions.Division

  @root_url "http://portlandvolleyball.bonzidev.com"
  @divisions_page "/home.php?layout=9543937"

  def get_divisions do
    "#{@root_url}#{@divisions_page}"
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Meeseeks.one(css("div.st-tkt-directory ul"))
    |> Meeseeks.all(css("li span.st-tkt-directory-item a"))
    |> Enum.map(fn link ->
      %Division{
        name: Meeseeks.text(link),
        url: @root_url <> Meeseeks.attr(link, "href")
      }
    end)
  end
end
