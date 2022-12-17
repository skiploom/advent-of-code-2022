defmodule Day15Test do
  use ExUnit.Case, async: true
  alias AdventOfCode2022.Day15
  doctest Day15

  describe "example puzzle" do
    test "correctly solves part 1" do
      assert Day15.part_one(example(), 10) == 26
    end
  end

  describe "calculate_distance/2" do
    test "returns the Manhattan distance between two points" do
      # Manhattan distance: https://en.wikipedia.org/wiki/Taxicab_geometry
      assert Day15.calculate_distance({1, 1}, {7, 7}) == 12
    end
  end

  describe "parse_into_pair/1" do
    test "parses an input line string into a tuple of sensor positions and beacon positions" do
      assert {{2, 18}, {-2, 15}} == Day15.parse_into_pair(List.first(example()))
    end
  end

  def example() do
    """
    Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    Sensor at x=9, y=16: closest beacon is at x=10, y=16
    Sensor at x=13, y=2: closest beacon is at x=15, y=3
    Sensor at x=12, y=14: closest beacon is at x=10, y=16
    Sensor at x=10, y=20: closest beacon is at x=10, y=16
    Sensor at x=14, y=17: closest beacon is at x=10, y=16
    Sensor at x=8, y=7: closest beacon is at x=2, y=10
    Sensor at x=2, y=0: closest beacon is at x=2, y=10
    Sensor at x=0, y=11: closest beacon is at x=2, y=10
    Sensor at x=20, y=14: closest beacon is at x=25, y=17
    Sensor at x=17, y=20: closest beacon is at x=21, y=22
    Sensor at x=16, y=7: closest beacon is at x=15, y=3
    Sensor at x=14, y=3: closest beacon is at x=15, y=3
    Sensor at x=20, y=1: closest beacon is at x=15, y=3
    """
    |> String.split("\n", trim: true)
  end
end
