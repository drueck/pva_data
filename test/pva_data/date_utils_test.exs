defmodule PVAData.DateUtilsTest do
  use ExUnit.Case, async: true

  alias PVAData.DateUtils

  describe "guess_year/2" do
    test "it guesses the next year when appropriate" do
      assert DateUtils.guess_year(1, ~D[2019-12-01]) == 2020
      assert DateUtils.guess_year(2, ~D[2019-11-01]) == 2020
    end

    test "it guessses the current year when appropriate" do
      assert DateUtils.guess_year(3, ~D[2019-10-01]) == 2019
      assert DateUtils.guess_year(4, ~D[2019-09-01]) == 2019
      assert DateUtils.guess_year(5, ~D[2019-08-01]) == 2019
      assert DateUtils.guess_year(6, ~D[2019-07-01]) == 2019
      assert DateUtils.guess_year(7, ~D[2019-06-01]) == 2019
      assert DateUtils.guess_year(8, ~D[2019-05-01]) == 2019
      assert DateUtils.guess_year(9, ~D[2019-04-01]) == 2019
      assert DateUtils.guess_year(10, ~D[2019-03-01]) == 2019
    end

    test "it guesses the previous year when appropriate" do
      assert DateUtils.guess_year(11, ~D[2019-02-01]) == 2018
      assert DateUtils.guess_year(12, ~D[2019-01-01]) == 2018
    end
  end
end
