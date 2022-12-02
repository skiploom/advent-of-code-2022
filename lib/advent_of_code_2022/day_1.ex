defmodule AdventOfCode2022.Day1 do
  @type calories :: integer()
  @type elf_food :: calories()
  @type elf_food_bag :: [elf_food()]

  @type answer :: {part1 :: integer(), part2 :: integer()}
  def answer() do
    inputs = read!()
    part1 = hd(find_most_calorically_dense_bags(inputs, 1))
    part2 = Enum.sum(find_most_calorically_dense_bags(inputs, 3))
    {part1, part2}
  end

  @spec find_most_calorically_dense_bags(bags :: elf_food_bag(), integer()) :: [elf_food_bag()]
  def find_most_calorically_dense_bags(bags, num_bags) do
    bags
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(num_bags)
  end

  def read!() do
    File.read!("inputs/day_1.txt")
    |> String.split(~r{\n})
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
    |> Enum.map(fn elf_food -> Enum.map(elf_food, &String.to_integer/1) end)
  end
end
