defmodule AdventOfCode2022.Day3 do
  use AdventOfCode2022.Solution

  @items Map.new(
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
    |> Enum.map(&parse_into_compartmentalized_rucksack/1)
    |> Enum.map(&find_misplaced_item/1)
    |> sum_priorities()
  end

  def part_two() do
    read_lines!(trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(&find_badge/1)
    |> sum_priorities()
  end

  def find_misplaced_item({compartment1, compartment2}) do
    [misplaced_item] = MapSet.to_list(MapSet.intersection(compartment1, compartment2))
    misplaced_item
  end

  def find_badge(group) do
    [rucksack1, rucksack2, rucksack3] =
      group
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.map(&MapSet.new/1)

    [badge] =
      MapSet.intersection(rucksack1, rucksack2)
      |> MapSet.intersection(rucksack3)
      |> MapSet.to_list()

    badge
  end

  def get_priority(item), do: Map.get(@items, item)

  def sum_priorities(items),
    do: Enum.reduce(items, 0, fn item, acc -> get_priority(item) + acc end)

  # Boring parsing functions
  def parse_into_compartmentalized_rucksack(str),
    do: build_compartmentalized_rucksack(parse_line(str))

  def build_compartmentalized_rucksack({str1, str2}),
    do: {to_compartment(str1), to_compartment(str2)}

  def to_compartment(str), do: MapSet.new(String.split(str, "", trim: true))
  def parse_line(line), do: String.split_at(line, div(String.length(line), 2))
end
