defmodule PVAData.ComputedId do
  defmacro __using__(keys: keys) do
    quote do
      def new(attrs) do
        struct = struct(__MODULE__, attrs)
        Map.put(struct, :id, id(struct))
      end

      def id(struct) do
        struct
        |> Map.take(unquote(keys))
        |> Map.values()
        |> Enum.map(&inspect/1)
        |> (fn values -> :crypto.hash(:md5, values) end).()
        |> Base.encode16()
        |> String.downcase()
      end
    end
  end
end
