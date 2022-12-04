defmodule AdventOfCode2022.Day4 do
  use AdventOfCode2022.Solution

  def part_one() do
    read_lines!(trim: true)
    |> Enum.map(&parse_into_range_pairs/1)
    |> Enum.count(&range_contains_other_range?/1)
  end

  def part_two() do
    read_lines!(trim: true)
    |> Enum.map(&parse_into_range_pairs/1)
    |> Enum.count(&ranges_overlap?/1)
  end

  def range_contains_other_range?(range_pair) do
    [set1, set2] = Enum.map(range_pair, &MapSet.new/1)
    MapSet.subset?(set1, set2) or MapSet.subset?(set2, set1)
  end

  def ranges_overlap?(range_pair) do
    [set1, set2] = Enum.map(range_pair, &MapSet.new/1)
    not MapSet.disjoint?(set1, set2)
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day4.parse_into_range_pairs("51-88,52-87")
      [51..88, 52..87]
  """
  def parse_into_range_pairs(str), do: Enum.map(String.split(str, ","), &parse_into_range/1)

  @doc ~S"""
      iex> AdventOfCode2022.Day4.parse_into_range("51-88")
      51..88
  """
  def parse_into_range(str) do
    [first, last] =
      str
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    Range.new(first, last)
  end
end
