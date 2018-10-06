defmodule PVADataWeb.Resolvers.Division do
  alias PVAData.Data
  alias PVAData.Divisions.Division

  def all(_args, _resolution) do
    divisions_with_name_only =
      Data.get_division_names()
      |> Enum.map(fn name -> %Division{name: name} end)

    {:ok, divisions_with_name_only}
  end
end
