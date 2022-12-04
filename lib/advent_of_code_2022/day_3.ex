defmodule AdventOfCode2022.Day3 do
  use AdventOfCode2022.Solution

  @type item :: String.t()
  @type rucksack :: [item()]
  @type bisected_rucksack :: {[item()], [item()]}

  @item_priorities Map.new(
                     Enum.with_index(
                       [
                         "a",
                         "b",
                         "c",
                         "d",
                         "e",
                         "f",
                         "g",
                         "h",
                         "i",
                         "j",
                         "k",
                         "l",
                         "m",
                         "n",
                         "o",
                         "p",
                         "q",
                         "r",
                         "s",
                         "t",
                         "u",
                         "v",
                         "w",
                         "x",
                         "y",
                         "z",
                         "A",
                         "B",
                         "C",
                         "D",
                         "E",
                         "F",
                         "G",
                         "H",
                         "I",
                         "J",
                         "K",
                         "L",
                         "M",
                         "N",
                         "O",
                         "P",
                         "Q",
                         "R",
                         "S",
                         "T",
                         "U",
                         "V",
                         "W",
                         "X",
                         "Y",
                         "Z"
                       ],
                       1
                     )
                   )

  def part_one() do
    read_lines!(trim: true)
    |> bisect_rucksacks()
    |> Enum.map(&find_misplaced_item/1)
    |> sum_priorities()
  end

  def part_two() do
    read_lines!(trim: true)
    |> group_rucksacks()
    |> Enum.map(&find_misplaced_item/1)
    |> sum_priorities()
  end

  @spec find_misplaced_item(bisected_rucksack()) :: item()
  def find_misplaced_item({c1, c2}), do: find_misplaced_item([c1, c2])

  @spec find_misplaced_item([rucksack()]) :: item()
  def find_misplaced_item(rucksacks) do
    rucksacks
    |> Enum.map(&MapSet.new/1)
    |> intersection()
    |> MapSet.to_list()
    |> hd()
  end

  def intersection([items1, items2]), do: MapSet.intersection(items1, items2)
  def intersection([items1 | rest]), do: MapSet.intersection(items1, intersection(rest))

  def sum_priorities(items), do: Enum.reduce(items, 0, fn i, acc -> get_priority(i) + acc end)
  def get_priority(item), do: Map.get(@item_priorities, item)

  def bisect_rucksacks(lines), do: Enum.map(lines, &bisect_rucksack(parse_to_rucksack(&1)))
  def bisect_rucksack(rucksack), do: Enum.split(rucksack, div(length(rucksack), 2))

  def group_rucksacks(lines) do
    lines
    |> Enum.map(&parse_to_rucksack/1)
    |> Enum.chunk_every(3)
  end

  def parse_to_rucksack(line), do: String.split(line, "", trim: true)
end
