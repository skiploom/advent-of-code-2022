defmodule Day7Test do
  use ExUnit.Case, async: true
  alias AdventOfCode2022.Day7
  doctest Day7

  @example_from_website """
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

  describe "can get the expected answers to the example puzzle" do
    test "part_one/0" do
      expected = 95437

      actual =
        @example_from_website
        |> String.split("\n", trim: true)
        |> Day7.get_directories_total_sizes()
        |> Map.values()
        |> Enum.filter(&(&1 < 100_000))
        |> Enum.sum()

      assert actual == expected
    end

    test "part_two/0" do
      expected = 24_933_642

      directory_sizes =
        Day7.get_directories_total_sizes(String.split(@example_from_website, "\n", trim: true))

      outermost_dir_size = Map.get(directory_sizes, ["/"])
      space_to_free_up = 30_000_000 - (70_000_000 - outermost_dir_size)

      actual =
        directory_sizes
        |> Map.values()
        |> Enum.filter(&(&1 >= space_to_free_up))
        |> Enum.min()

      assert actual == expected
    end
  end
end
