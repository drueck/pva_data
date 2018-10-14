defmodule PVADataWeb.Schema.Scalars.Time do
  def serialize(%Time{} = time), do: Time.to_iso8601(time)

  def parse(%Absinthe.Blueprint.Input.String{value: value}) do
    case Time.from_iso8601(value) do
      {:ok, time} -> {:ok, time}
      {:error, _} -> :error
    end
  end

  def parse(%Absinthe.Blueprint.Input.Null{}), do: {:ok, nil}

  def parse(_), do: :error
end
