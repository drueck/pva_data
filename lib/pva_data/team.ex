defmodule PVAData.Team do
  use PVAData.ComputedId, keys: [:name, :division_id]

  alias PVAData.{
    Team,
    Division
  }

  defstruct [:id, :name, :division_id, :slug, :rank_reason, rank: 0]

  def build(%Division{id: division_id}, name) do
    Team.new(
      name: name,
      slug: Slugger.slugify_downcase(name),
      division_id: division_id
    )
  end
end
