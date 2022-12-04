defmodule AdventOfCode2022.Day1 do
  use AdventOfCode2022.Solution

  def part_one(), do: hd(find_most_calorically_dense_bags(bags(), 1))
  def part_two(), do: Enum.sum(find_most_calorically_dense_bags(bags(), 3))

  def find_most_calorically_dense_bags(bags, num_bags) do
    bags
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(num_bags)
  end

  def bags() do
    read_lines!()
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
    |> Enum.map(fn bag -> Enum.map(bag, &String.to_integer/1) end)
  end
end
