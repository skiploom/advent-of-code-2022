defmodule AdventOfCode2022.Day7 do
  use AdventOfCode2022.Solution

  @total_space_available 70_000_000
  @space_needed_for_update 30_000_000

  def part_one() do
    read_lines!(trim: true)
    |> get_directories_total_sizes()
    |> Map.values()
    |> Enum.filter(&(&1 < 100_000))
    |> Enum.sum()
  end

  def part_two() do
    directory_sizes = get_directories_total_sizes(read_lines!(trim: true))
    outermost_dir_size = Map.get(directory_sizes, ["/"])
    space_to_free_up = @space_needed_for_update - (@total_space_available - outermost_dir_size)

    directory_sizes
    |> Map.values()
    |> Enum.filter(&(&1 >= space_to_free_up))
    |> Enum.min()
  end

  @doc """
  Generates a map whose keys are every directory found in a filesystem,
  and whose values are their total sizes
  (i.e. the sums of the sizes of their files and of the files within their subdirectories),
  based on a list of terminal output of some Elves changing directories and listing their contents.

      iex> terminal_output = ~s\"""
      ...> $ cd /
      ...> $ ls
      ...> dir fooze
      ...> 333 bat.bat
      ...> $ cd fooze
      ...> $ ls
      ...> 100 foo.txt
      ...> 200 bar.mp3
      ...> \"""
      ...> |> String.split("\\n", trim: true)
      ...>
      ...> AdventOfCode2022.Day7.get_directories_total_sizes(terminal_output)
      %{["/"] => 633, ["/", "fooze"] => 300}
  """
  @spec get_directories_total_sizes(terminal_output :: [String.t()]) :: map()
  def get_directories_total_sizes(output) do
    output
    |> parse_terminal_output({[], %{}})
    |> replace_child_dirs_with_sizes()
    |> Enum.map(fn {k, v} -> {k, Enum.sum(v)} end)
    |> Map.new()
  end

  @spec parse_terminal_output(
          terminal_output :: [String.t()],
          {current_path :: [String.t()], acc :: map()}
        ) :: map()
  def parse_terminal_output([], {_, acc}), do: acc

  def parse_terminal_output([curr | rest], path_and_acc) do
    parse_terminal_output(rest, set_dirmap(classify(curr), path_and_acc))
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

  def set_dirmap({:cd, :back}, {path, acc}), do: {Enum.drop(path, -1), acc}
  def set_dirmap({:cd, d}, {path, acc}), do: {path ++ [d], Map.put_new(acc, path ++ [d], [])}
  def set_dirmap(:ls, {path, acc}), do: {path, acc}
  def set_dirmap({:dir, d}, {path, acc}), do: {path, Map.update(acc, path, [d], &[d | &1])}
  def set_dirmap({:file, s}, {path, acc}), do: {path, Map.update(acc, path, [s], &[s | &1])}

  def replace_child_dirs_with_sizes(dirmap) do
    Enum.map(dirmap, &replace_and_flatten(&1, dirmap))
  end

  def replace_and_flatten({path, contents}, dirmap) do
    {path, List.flatten(Enum.map(contents, &parse_content(&1, path, dirmap)))}
  end

  def parse_content(content, path, dirmap) do
    case Integer.parse(content) do
      {filesize, _} -> filesize
      :error -> parse_nested_directory(content, path, dirmap)
    end
  end

  def parse_nested_directory(dir, path, dirmap) do
    directory_path = path ++ [dir]
    directory_contents = Map.get(dirmap, directory_path)

    Enum.map(directory_contents, &parse_content(&1, directory_path, dirmap))
  end
end
