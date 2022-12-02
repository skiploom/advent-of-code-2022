defmodule Day1Test do
  use ExUnit.Case

  test "given a list of lists of integers and a desired number n, returns the sums of the n-th greatest lists" do
    elf_food_bags = [[1, 2, 3], [70], [100, 200], [400, 20]]
    assert AdventOfCode2022.Day1.find_most_calorically_dense_bags(elf_food_bags, 1) == [420]
    assert AdventOfCode2022.Day1.find_most_calorically_dense_bags(elf_food_bags, 2) == [420, 300]
  end
end
