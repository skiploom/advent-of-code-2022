# Creates an empty solution module, test module, and input text file for a given Advent of Code 2022 day.
defmodule Init do
  @spec init(day_number :: String.t()) :: any()
  def init(d) do
    if File.exists?("lib/advent_of_code_2022/day_#{d}.ex") do
      raise "You've already created files for Day #{d}."
    else
      File.write!("lib/advent_of_code_2022/day_#{d}.ex", solution_module_content(d))
      File.write!("inputs/day_#{d}.txt", "")
      File.write!("test/day_#{d}_test.exs", test_module_content(d))
    end
  end

  defp solution_module_content(day_number) do
    """
    defmodule AdventOfCode2022.Day#{day_number} do
      use AdventOfCode2022.Solution

      def part_one() do
      end

      def part_two() do
      end
    end
    """
  end

  defp test_module_content(day_number) do
    """
    defmodule Day#{day_number}Test do
      use ExUnit.Case, async: true
      alias AdventOfCode2022.Day#{day_number}
      doctest Day#{day_number}

    end
    """
  end
end

arg =
  case System.argv() do
    [day_number | _] ->
      day_number

    [] ->
      raise "Please pass in the Advent Of Code 2022 day number."
  end

Init.init(arg)
