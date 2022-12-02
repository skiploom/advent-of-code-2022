defmodule AdventOfCode2022Test do
  use ExUnit.Case
  doctest AdventOfCode2022

  describe "AdventOfCode2022.answer/1" do
    test "returns a tuple of two integers when given a valid day number" do
      {part1, part2} = AdventOfCode2022.answer(1)
      assert is_integer(part1)
      assert is_integer(part2)
    end

    test "raises an error when given an invalid day number" do
      assert_raise ArgumentError, fn -> AdventOfCode2022.answer("foo") end
    end
  end
end
