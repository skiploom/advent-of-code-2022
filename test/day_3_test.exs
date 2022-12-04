defmodule Day3Test do
  use ExUnit.Case

  alias AdventOfCode2022.Day3

  describe "find_misplaced_item/1" do
    test "finds the common item between two parts of a rucksack" do
      rucksack = {["a", "b", "c", "C"], ["x", "C", "z"]}
      assert Day3.find_misplaced_item(rucksack) == "C"
    end
  end

  describe "sum_priorities/1" do
    test "sums the priorities of the given items" do
      items = ["f", "o", "O"]
      expected = Enum.sum(Enum.map(items, &Day3.get_priority/1))
      assert Day3.sum_priorities(items) == expected
    end
  end

  describe "bisect_rucksack/1" do
    test "splits a rucksack into two equal parts" do
      assert Day3.bisect_rucksack(["f", "o", "o", "b", "a", "r"]) ==
               {["f", "o", "o"], ["b", "a", "r"]}
    end
  end

  describe "group_rucksacks/1" do
    test "returns a list of 3-rucksack-lists, given a list of rucksack strings" do
      rucksack_str = "foo"
      rucksack = ["f", "o", "o"]
      input = List.duplicate(rucksack_str, 9)

      assert Day3.group_rucksacks(input) ==
               [
                 [rucksack, rucksack, rucksack],
                 [rucksack, rucksack, rucksack],
                 [rucksack, rucksack, rucksack]
               ]
    end
  end
end
