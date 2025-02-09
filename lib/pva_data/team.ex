defmodule PVAData.Team do
  use PVAData.ComputedId, keys: [:name, :division_id]

  alias PVAData.{
    Team,
    Division
  }

  defstruct [:id, :name, :division_id, :slug, :contact, :rank_reason, rank: 0]

  def build(%Division{id: division_id}, name) do
    trimmed_name = String.trim(name)

    Team.new(
      name: trimmed_name,
      slug: Slugger.slugify_downcase(trimmed_name),
      division_id: division_id
    )
  end
end
