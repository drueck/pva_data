defmodule PVAData.DateUtils do
  def guess_year(referenced_month, today) do
    case referenced_month do
      m when m in 1..2 ->
        if today.month > 10, do: today.year + 1, else: today.year

      m when m in 10..12 ->
        if today.month < 3, do: today.year - 1, else: today.year

      _ ->
        today.year
    end
  end
end
