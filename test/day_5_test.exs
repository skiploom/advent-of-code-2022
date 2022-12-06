defmodule Day5Test do
  use ExUnit.Case, async: true
  alias AdventOfCode2022.Day5
  doctest Day5

  @example_from_website [
    "    [D]    ",
    "[N] [C]    ",
    "[Z] [M] [P]",
    " 1   2   3 ",
    # a newline here would be trimmed by the read_lines! macro
    "move 1 from 2 to 1",
    "move 3 from 1 to 3",
    "move 2 from 2 to 1",
    "move 1 from 1 to 2"
  ]

  describe "can get the expected answers to the example puzzle" do
    test "part_one/0 correctly solves the example puzzle" do
      expected = "CMZ"

      {stacks, procedure} = Day5.parse_into_stacks_and_procedure(@example_from_website)

      actual =
        procedure
        |> Day5.rearrange(stacks, &Day5.move_one_at_a_time/2)
        |> Day5.generate_message()

      assert actual == expected
    end

    test "part_two/0 correctly solves the example puzzle" do
      expected = "MCD"

      {stacks, procedure} = Day5.parse_into_stacks_and_procedure(@example_from_website)

      actual =
        procedure
        |> Day5.rearrange(stacks, &Day5.move_all_at_once/2)
        |> Day5.generate_message()

      assert actual == expected
    end
  end
end
