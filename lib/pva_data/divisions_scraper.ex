defmodule PVAData.DivisionsScraper do
  import Meeseeks.CSS

  @divisions_list_url "http://portlandvolleyball.bonzidev.com/home.php?layout=9543937"

  def get_divisions do
    with %{body: body} <- HTTPoison.get!(@divisions_list_url),
         directory_list <- Meeseeks.one(body, css("div.st-tkt-directory ul")),
         division_links <- Meeseeks.all(directory_list, css("li span.st-tkt-directory-item a")) do
      division_links
      |> Enum.map(fn link ->
        %{name: Meeseeks.text(link), url: Meeseeks.attr(link, "href")}
      end)
    end
  end
end
