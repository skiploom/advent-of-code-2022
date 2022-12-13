defmodule Day12Test do
  use ExUnit.Case, async: true
  alias AdventOfCode2022.Day12
  doctest Day12

  describe "solves the example puzzle" do
    test "part_one/0" do
      expected = 31

      actual =
        example()
        |> String.split("\n", trim: true)
        |> Day12.parse_into_state()
        |> Day12.find_shortest_path()

      assert actual == expected
    end
  end

  defp example() do
    """
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
    """
  end
end
