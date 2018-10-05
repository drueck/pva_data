defmodule PVAData.DataTest do
  use ExUnit.Case, async: true

  alias PVAData.Data

  setup do
    data = start_supervised!(Data)
    %{data: data}
  end
end
