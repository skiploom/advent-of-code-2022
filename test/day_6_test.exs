defmodule Day6Test do
  use ExUnit.Case, async: true
  alias AdventOfCode2022.Day6
  doctest Day6

  describe "functions correctly solve example inputs on the puzzle website" do
    test "find_marker_location/2 works for part one" do
      example_inputs_and_answers = [
        {"mjqjpqmgbljsphdztnvjfqwrcgsmlb", 7},
        {"bvwbjplbgvbhsrlpgdmjqwftvncz", 5},
        {"nppdvjthqldpwncqszvftbrmjlhg", 6},
        {"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10},
        {"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11}
      ]

      assert Enum.all?(example_inputs_and_answers, fn {input, answer} ->
               Day6.find_marker_location(input, 4) == answer
             end)
    end

    test "part_two/0" do
      example_inputs_and_answers = [
        {"mjqjpqmgbljsphdztnvjfqwrcgsmlb", 19},
        {"bvwbjplbgvbhsrlpgdmjqwftvncz", 23},
        {"nppdvjthqldpwncqszvftbrmjlhg", 23},
        {"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 29},
        {"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 26}
      ]

      assert Enum.all?(example_inputs_and_answers, fn {input, answer} ->
               Day6.find_marker_location(input, 14) == answer
             end)
    end
  end
end
