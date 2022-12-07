defmodule AdventOfCode2022.Day7 do
  use AdventOfCode2022.Solution

  def part_one() do
    read_lines!(trim: true)
    |> process([], %{})
    |> replace()
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&Enum.sum/1)
    |> Enum.filter(&(&1 < 100_000))
    |> Enum.sum()
  end

  def part_two() do
  end

  def process() do
    read_example_lines()
    |> process([], %{})
    |> replace()
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&Enum.sum/1)
    |> Enum.filter(&(&1 < 100_000))
    |> Enum.sum()
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
    Enum.map(map, &replace(&1, map))
  end

  def replace({path, v}, map) do
    Enum.map(v, &do_replace(&1, path, map))
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

  def read_example_lines() do
    """
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    """
    |> String.split("\n", trim: true)
    |> IO.inspect()
  end
end
