defmodule Day4Test do
  use ExUnit.Case
  alias AdventOfCode2022.Day4
  doctest Day4

  describe "range_contains_other_range?/1" do
    test "returns true if, in a pair of ranges, one range contains the other" do
      assert Day4.range_contains_other_range?([1..4, 2..3])
      assert Day4.range_contains_other_range?([2..3, 1..4])

      refute Day4.range_contains_other_range?([1..4, 5..6])
      refute Day4.range_contains_other_range?([1..4, 100..110])
      refute Day4.range_contains_other_range?([1..4, 2..5])
    end
  end

  describe "ranges_overlap?/1" do
    test "returns true if, in a pair of ranges, the ranges overlap at all" do
      assert Day4.ranges_overlap?([1..4, 2..3])
      assert Day4.ranges_overlap?([2..3, 1..4])

      refute Day4.ranges_overlap?([1..4, 5..6])
      refute Day4.ranges_overlap?([1..4, 100..110])
      assert Day4.ranges_overlap?([1..4, 2..5])
    end
  end
end
