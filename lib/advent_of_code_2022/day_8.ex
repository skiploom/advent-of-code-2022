defmodule AdventOfCode2022.Day8 do
  use AdventOfCode2022.Solution

  def part_one() do
    rows_and_cols = parse_into_rows_and_columns(read_lines!(trim: true))
    trees = parse_into_flat_list(read_lines!(trim: true))

    Enum.reduce(trees, 0, fn tree, num_visible ->
      pov = build_tree_pov(tree, rows_and_cols)

      if visible?(tree, pov) do
        num_visible + 1
      else
        num_visible
      end
    end)
  end

  def part_two() do
    rows_and_cols = parse_into_rows_and_columns(read_lines!(trim: true))
    trees = parse_into_flat_list(read_lines!(trim: true))

    Enum.reduce(trees, 0, fn tree, max_scenic_score ->
      pov = build_tree_pov(tree, rows_and_cols)
      scenic_score = calculate_scenic_score(calculate_viewing_distances(tree, pov))

      if scenic_score > max_scenic_score do
        scenic_score
      else
        max_scenic_score
      end
    end)
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day8.parse_into_rows_and_columns(["12", "24"])
      %{rows: %{0 => [1, 2], 1 => [2, 4]}, columns: %{0 => [1, 2], 1 => [2, 4]}}
  """
  def parse_into_rows_and_columns(input_lines) do
    tree_matrix =
      input_lines
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.map(&Enum.map(&1, fn height -> String.to_integer(height) end))

    rows =
      tree_matrix
      |> Enum.with_index(fn heights, row_num -> {row_num, heights} end)
      |> Map.new()

    columns =
      tree_matrix
      |> Enum.flat_map(&Enum.with_index(&1, fn height, col_num -> {col_num, height} end))
      |> Enum.reduce(%{}, fn {col_num, height}, acc ->
        Map.update(acc, col_num, [height], fn existing_heights -> existing_heights ++ [height] end)
      end)

    %{rows: rows, columns: columns}
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day8.parse_into_flat_list(["12", "24"])
      [%{row: 0, column: 0, height: 1}, %{row: 0, column: 1, height: 2}, %{row: 1, column: 0, height: 2}, %{row: 1, column: 1, height: 4}]
  """
  def parse_into_flat_list(input_lines) do
    tree_matrix =
      input_lines
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.map(&Enum.map(&1, fn height -> String.to_integer(height) end))

    tree_matrix
    |> Enum.with_index(fn height, row_num -> {height, row_num} end)
    |> Enum.flat_map(fn {row, row_num} ->
      Enum.with_index(row, fn height, col_num ->
        build_tree(col_num, row_num, height)
      end)
    end)
  end

  def build_tree(col_num, row_num, height), do: %{column: col_num, row: row_num, height: height}

  def calculate_scenic_score(distances), do: Enum.reduce(distances, fn x, acc -> x * acc end)

  def calculate_viewing_distances(tree, pov) do
    Enum.map(pov, &calculate_viewing_distance(tree, &1, 0))
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day8.calculate_viewing_distance(%{height: 2}, [], 0)
      0

      iex> AdventOfCode2022.Day8.calculate_viewing_distance(%{height: 2}, [1, 0, 1], 0)
      3

      iex> AdventOfCode2022.Day8.calculate_viewing_distance(%{height: 2}, [1, 2, 1], 0)
      2

      iex> AdventOfCode2022.Day8.calculate_viewing_distance(%{height: 2}, [2, 0, 1], 0)
      1

      iex> AdventOfCode2022.Day8.calculate_viewing_distance(%{height: 2}, [1, 0, 2], 0)
      3
  """
  def calculate_viewing_distance(_, [], distance), do: distance

  def calculate_viewing_distance(tree, [head | rest] = _pov, distance) do
    if tree.height > head do
      calculate_viewing_distance(tree, rest, distance + 1)
    else
      distance + 1
    end
  end

  @doc ~S"""
  Returns a list of lists,
  where each sublist has the heights of the trees you can view from your treehouse from a certain direction.

  Each sublist is ordered such that the first element represents the tree right next to your treehouse,
  and the last element represents the tree at the edge of the entire tree patch.
  (Therefore, the lists do not contain the height of your treehouse's tree.)

  There are four lists, which represent the four directions from which you can view trees: north, east, south, and west.

      iex> tree = %{row: 0, column: 1, height: 2}
      ...> rows_and_cols = AdventOfCode2022.Day8.parse_into_rows_and_columns(["123", "456", "789"])
      ...> AdventOfCode2022.Day8.build_tree_pov(tree, rows_and_cols)
      [[], [3], [5, 8], [1]]
  """
  def build_tree_pov(tree, rows_and_cols) do
    row = Map.get(rows_and_cols.rows, tree.row)
    column = Map.get(rows_and_cols.columns, tree.column)
    {left_trees, [_curr_tree | right_trees]} = Enum.split(row, tree.column)
    {up_trees, [_curr_tree | down_trees]} = Enum.split(column, tree.row)

    [Enum.reverse(up_trees), right_trees, down_trees, Enum.reverse(left_trees)]
  end

  def visible?(tree, pov) do
    Enum.any?(pov, &visible?(tree, &1, true))
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day8.visible?(%{height: 2}, [1, 0, 1], true)
      true

      iex> AdventOfCode2022.Day8.visible?(%{height: 2}, [1, 2, 1], true)
      false

      iex> AdventOfCode2022.Day8.visible?(%{height: 2}, [2, 0, 1], true)
      false

      iex> AdventOfCode2022.Day8.visible?(%{height: 2}, [1, 0, 2], true)
      false
  """
  def visible?(_, _, false), do: false
  def visible?(_, [], is_visible), do: is_visible

  def visible?(tree, [head | rest] = _pov, _is_visible) do
    visible?(tree, rest, tree.height > head)
  end
end
