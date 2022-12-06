# Creates an empty solution module, test module, and input text file for a given Advent of Code 2022 day.
defmodule Init do
  @spec init(day_number :: String.t()) :: any()
  def init(d) do
    if File.exists?("lib/advent_of_code_2022/day_#{d}.ex") do
      raise "You've already created files for Day #{d}."
    else
      solution_module_path = "lib/advent_of_code_2022/day_#{d}.ex"
      inputs_file_path = "inputs/day_#{d}.txt"
      test_module_path = "test/day_#{d}_test.exs"

      File.write!(solution_module_path, solution_module_content(d))
      File.write!(inputs_file_path, "")
      File.write!(test_module_path, test_module_content(d))

      IO.puts(~s"""
      Three files have been created:

      🌟 #{solution_module_path}
      🌟 #{inputs_file_path}
      🌟 #{test_module_path}


      Good luck on Day #{d}!
      """)
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
