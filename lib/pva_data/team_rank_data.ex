defmodule PVAData.TeamRankData do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end)
  end

  def get(data, team_ids) do
    Agent.get(data, &Map.get(&1, team_ids))
  end

  def put(data, team_ids, rank_data) do
    Agent.update(data, &Map.put(&1, team_ids, rank_data))
  end
end
