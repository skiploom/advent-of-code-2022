defmodule Day11Test do
  use ExUnit.Case, async: true
  alias AdventOfCode2022.Day11
  alias AdventOfCode2022.Day11.Monkey
  doctest Day11

  describe "fling/4" do
    test "successfully throws an item from one monkey to another" do
      monkeys_map = Day11.build_monkeys_map(build_monkeys())
      source_monkey = 0
      recipient_monkey = 1
      item = 1

      new_map = Day11.fling(monkeys_map, 0, 1, item)

      assert new_map[source_monkey].items == [2]
      assert new_map[recipient_monkey].items == [3, 1]
      assert new_map[2] == monkeys_map[2]
    end
  end

  defp build_monkeys() do
    [
      %Monkey{
        name: 0,
        items: [1, 2],
        operation: fn x -> x * 2 end,
        test: 2,
        true_recipient: 2,
        false_recipient: 1,
        inspect_count: 0
      },
      %Monkey{
        name: 1,
        items: [3],
        operation: fn x -> x + 1 end,
        test: 3,
        true_recipient: 2,
        false_recipient: 0,
        inspect_count: 0
      },
      %Monkey{
        name: 2,
        items: [4, 5],
        operation: fn x -> x * x end,
        test: 4,
        true_recipient: 0,
        false_recipient: 1,
        inspect_count: 0
      }
    ]
  end
end
