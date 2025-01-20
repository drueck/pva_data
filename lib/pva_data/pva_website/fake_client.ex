defmodule PVAData.PVAWebsite.FakeClient do
  alias PVAData.PVAWebsite.{
    DivisionListParser,
    DivisionParser
  }

  @behaviour PVAData.PVAWebsite.ClientBehaviour

  @base_path "test/fixtures"

  def get_division_urls(base_path \\ nil) do
    "#{base_path || @base_path}/schedules"
    |> File.read!()
    |> DivisionListParser.get_division_urls()
  end

  def get_division(base_path \\ nil, division_path) do
    "#{base_path || @base_path}/#{division_path}"
    |> File.read!()
    |> DivisionParser.get_division()
  end
end
