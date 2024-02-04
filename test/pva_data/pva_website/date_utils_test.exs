defmodule PVAData.PVAWebsite.DateUtilsTest do
  use ExUnit.Case, async: true

  alias PVAData.PVAWebsite.DateUtils

  describe "parse_date/1" do
    test "parses the date format used on the PVA website" do
      assert %Date{} = date = DateUtils.parse_date("4/08 (Mon)")
      assert date.month == 4
      assert date.day == 8
      assert date.year == Date.utc_today().year
    end
  end

  describe "parse_time/1" do
    test "it parses the time format used on the PVA website" do
      assert DateUtils.parse_time("8:00") == ~T[20:00:00]
    end

    test "it parses the time with PM" do
      assert DateUtils.parse_time("9:30 PM") == ~T[21:30:00]
    end

    test "it parses just an hour without minutes" do
      assert DateUtils.parse_time("7") == ~T[19:00:00]
    end

    test "it parses just an hour with PM" do
      assert DateUtils.parse_time("6 PM") == ~T[18:00:00]
    end
  end

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
