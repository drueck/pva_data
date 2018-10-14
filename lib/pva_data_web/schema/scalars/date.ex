defmodule PVADataWeb.Schema.Scalars.Date do
  def serialize(%Date{} = date), do: Date.to_iso8601(date)

  def parse(%Absinthe.Blueprint.Input.String{value: value}) do
    case Date.from_iso8601(value) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> :error
    end
  end

  def parse(%Absinthe.Blueprint.Input.Null{}), do: {:ok, nil}

  def parse(_), do: :error
end
