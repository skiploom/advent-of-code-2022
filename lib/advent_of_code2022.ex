defmodule AdventOfCode2022 do
  @moduledoc """
  Solutions to the daily programming puzzles of [Advent of Code 2022](https://adventofcode.com/2022/about).
  """

  @type answers :: {part1 :: integer() | String.t(), part2 :: integer() | String.t()}

  @doc "Runs the solver functions for the puzzles of the given day."
  @spec answer(day_number :: integer()) :: answers()
  def answer(day_number) do
    day_module = String.to_existing_atom("Elixir.AdventOfCode2022.Day#{day_number}")
    {apply(day_module, :part_one, []), apply(day_module, :part_two, [])}
  end
end
