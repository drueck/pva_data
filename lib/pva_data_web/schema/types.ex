defmodule PVADataWeb.Schema.Types do
  use Absinthe.Schema.Notation

  alias PVADataWeb.Schema.Scalars
  alias PVADataWeb.Resolvers

  scalar :date, name: "Date" do
    serialize &Scalars.Date.serialize/1
    parse &Scalars.Date.parse/1
  end

  scalar :time, name: "Time" do
    serialize &Scalars.Time.serialize/1
    parse &Scalars.Time.parse/1
  end

  object :division do
    field :id, :string
    field :name, :string
    field :slug, :string
    field :teams, list_of(:team)
    field :standings, list_of(:standing)
    field :scheduled_matches, list_of(:match)
    field :completed_matches, list_of(:match)
  end

  object :team do
    field :id, :string
    field :name, :string
    field :slug, :string
    field :rank, :integer

    field :division, :division do
      resolve &Resolvers.Division.from_team/3
    end

    field :record, :standing do
      resolve &Resolvers.Standing.from_team/3
    end

    field :completed_matches, list_of(:match) do
      resolve &Resolvers.Match.completed_for_team/3
    end

    field :scheduled_matches, list_of(:match) do
      resolve &Resolvers.Match.scheduled_for_team/3
    end
  end

  object :standing do
    field :id, :string

    field :team, :team do
      resolve &Resolvers.Team.from_standing/3
    end

    field :division, :division do
      resolve &Resolvers.Division.from_standing/3
    end

    field :wins, :integer
    field :losses, :integer
    field :winning_percentage, :float
    field :match_points, :float
    field :match_points_possible, :float
    field :match_points_percentage, :float
    field :rank, :integer
  end

  object :match do
    field :id, :string
    field :date, :date
    field :time, :time

    field :division, :division do
      resolve &Resolvers.Division.from_match/3
    end

    field :home_team, :team do
      resolve &Resolvers.Team.home_team_from_match/3
    end

    field :visiting_team, :team do
      resolve &Resolvers.Team.visiting_team_from_match/3
    end

    field :location, :string
    field :court, :string
    field :ref, :string
    field :set_results, list_of(:set_result)
  end

  object :set_result do
    field :id, :string
    field :set_number, :integer
    field :home_team_score, :integer
    field :visiting_team_score, :integer
  end

  object :session do
    field :token, :string
  end
end
