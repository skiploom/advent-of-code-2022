defmodule AdventOfCode2022.Day7 do
  use AdventOfCode2022.Solution

  def part_one() do
    read_lines!(trim: true)
    |> process([], %{})
    |> replace()
    |> Map.values()
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&Enum.sum/1)
    |> Enum.filter(&(&1 < 100_000))
    |> Enum.sum()
  end

  def part_two() do
    directory_sizes =
      read_lines!(trim: true)
      |> process([], %{})
      |> replace()
      |> Enum.map(fn {path, contents} -> {path, Enum.sum(List.flatten(contents))} end)
      |> Map.new()

    outermost_directory_size = Map.get(directory_sizes, ["/"])
    unused_space = 70_000_000 - outermost_directory_size
    needed_unused_space = 30_000_000
    target = needed_unused_space - unused_space

    directory_sizes
    |> Map.values()
    |> Enum.filter(&(&1 >= target))
    |> Enum.min()
  end

  def process([], _, acc), do: acc

  def process([head | rest], curr, acc) do
    {new_curr, new_acc} =
      head
      |> classify()
      |> do_thing(curr, acc)

    process(rest, new_curr, new_acc)
  end

  def classify(cmd) do
    case String.split(cmd, " ", trim: true) do
      ["$", "cd", ".."] -> {:cd, :back}
      ["$", "cd", dir] -> {:cd, dir}
      ["$", "ls"] -> :ls
      ["dir", dir] -> {:dir, dir}
      [size, _file] -> {:file, size}
    end
  end

  def do_thing({:cd, :back}, curr, acc) do
    {Enum.drop(curr, -1), acc}
  end

  def do_thing({:cd, d}, curr, acc), do: {curr ++ [d], Map.put_new(acc, curr ++ [d], [])}
  def do_thing(:ls, curr, acc), do: {curr, acc}
  def do_thing({:dir, d}, curr, acc), do: {curr, Map.update(acc, curr, [d], &[d | &1])}
  def do_thing({:file, s}, curr, acc), do: {curr, Map.update(acc, curr, [s], &[s | &1])}

  def replace(map) do
    Map.new(Enum.map(map, &replace(&1, map)))
  end

  def replace({path, contents}, map) do
    {path, Enum.map(contents, &do_replace(&1, path, map))}
  end

  def do_replace(str, path, map) when is_binary(str) do
    case Integer.parse(str) do
      {int, _} -> int
      :error -> get_thingy(str, path, map)
    end
  end

  def get_thingy(dir, path, map) do
    Map.get(map, path ++ [dir])
    |> Enum.map(&do_replace(&1, path ++ [dir], map))
  end
end
