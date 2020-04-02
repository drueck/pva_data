defmodule PVADataWeb.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

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

    field :division, :division do
      resolve &Resolvers.Division.from_team/3
    end

    field :record, :standing do
      resolve &Resolvers.Standing.from_team/3
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
    field :ref, :string
    field :set_results, list_of(:set_result)
  end

  object :set_result do
    field :id, :string
    field :set_number, :integer
    field :home_team_score, :integer
    field :visiting_team_score, :integer
  end

  # node interface do
  #   resolve_type fn
  #     _, _ -> nil
  #   end
  # end

  # connection(node_type: :division)
  # connection(node_type: :team)
  # connection(node_type: :team_record)
  # connection(node_type: :match)

  # node object(:division) do
  #   field :name, :string

  #   connection field :teams, node_type: :team do
  #     resolve &Resolvers.Team.all_for_division/3
  #   end

  #   field :team, :team do
  #     arg :name, :string

  #     resolve &Resolvers.Team.get/3
  #   end

  #   connection field :standings, node_type: :team_record do
  #     resolve &Resolvers.TeamRecord.all_for_division/3
  #   end

  #   connection field :scores, node_type: :match do
  #     resolve &Resolvers.Match.scores_for_division/3
  #   end

  #   connection field :schedules, node_type: :match do
  #     resolve &Resolvers.Match.schedules_for_division/3
  #   end
  # end

  # node object(:team) do
  #   field :name, :string
  #   field :division, :division
  #   field :record, :team_record

  #   connection field :scores, node_type: :match do
  #     resolve &Resolvers.Match.scores_for_team/3
  #   end

  #   connection field :schedules, node_type: :match do
  #     resolve &Resolvers.Match.schedules_for_team/3
  #   end
  # end

  # node object(:team_record) do
  #   field :team_name, :string
  #   field :matches_won, :integer
  #   field :matches_lost, :integer
  #   field :matches_back, :float
  #   field :games_won, :integer
  #   field :games_lost, :integer
  # end

  # node object(:match) do
  #   field :date, :date
  #   field :time, :time
  #   field :location, :match_location
  #   field :home, :match_team
  #   field :visitor, :match_team
  # end

  # node object(:match_location) do
  #   field :name, :string
  #   field :map_url, :string
  # end

  # node object(:match_team) do
  #   field :name, :string
  #   field :games_won, :integer
  # end
end
