defmodule AdventOfCode2022.Day8 do
  use AdventOfCode2022.Solution

  def part_one() do
    %{tree_height_map: tree_height_map, tree_list: trees} = setup()

    Enum.reduce(trees, 0, fn tree, num_visible ->
      pov = build_tree_pov(tree, tree_height_map)

      if tree_visible_from_any_direction?(tree, pov) do
        num_visible + 1
      else
        num_visible
      end
    end)
  end

  def part_two() do
    %{tree_height_map: tree_height_map, tree_list: trees} = setup()

    Enum.reduce(trees, 0, fn tree, max_scenic_score ->
      pov = build_tree_pov(tree, tree_height_map)
      scenic_score = calculate_scenic_score(calculate_viewing_distances(tree, pov))

      if scenic_score > max_scenic_score do
        scenic_score
      else
        max_scenic_score
      end
    end)
  end

  def setup() do
    height_matrix = parse_into_tree_height_matrix(read_lines!(trim: true))

    %{
      tree_height_map: build_tree_height_map(height_matrix),
      tree_list: build_flat_tree_list(height_matrix)
    }
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day8.parse_into_tree_height_matrix(["12", "24"])
      [[1, 2], [2, 4]]
  """
  def parse_into_tree_height_matrix(input_lines) do
    input_lines
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(&Enum.map(&1, fn height -> String.to_integer(height) end))
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day8.build_tree_height_map([[1, 2], [2, 4]])
      %{rows: %{0 => [1, 2], 1 => [2, 4]}, columns: %{0 => [1, 2], 1 => [2, 4]}}
  """
  def build_tree_height_map(height_matrix) do
    rows =
      height_matrix
      |> Enum.with_index(fn heights, row_num -> {row_num, heights} end)
      |> Map.new()

    columns =
      height_matrix
      |> Enum.flat_map(&Enum.with_index(&1, fn height, col_num -> {col_num, height} end))
      |> Enum.reduce(%{}, fn {col_num, height}, acc ->
        Map.update(acc, col_num, [height], fn existing_heights -> existing_heights ++ [height] end)
      end)

    %{rows: rows, columns: columns}
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day8.build_flat_tree_list([[1, 2], [2, 4]])
      [%{row: 0, column: 0, height: 1}, %{row: 0, column: 1, height: 2}, %{row: 1, column: 0, height: 2}, %{row: 1, column: 1, height: 4}]
  """
  def build_flat_tree_list(height_matrix) do
    height_matrix
    |> Enum.with_index(fn height, row_num -> {height, row_num} end)
    |> Enum.flat_map(fn {row, row_num} ->
      Enum.with_index(row, fn height, col_num ->
        build_tree(col_num, row_num, height)
      end)
    end)
  end

  def build_tree(col_num, row_num, height), do: %{column: col_num, row: row_num, height: height}

  @doc ~S"""
  Returns a list of lists,
  where each sublist has the heights of the trees you can view from your treehouse from a certain direction.

  Each sublist is ordered such that the first element represents the tree right next to your treehouse,
  and the last element represents the tree at the edge of the entire tree patch.
  (Therefore, the lists do not contain the height of your treehouse's tree.)

  There are four lists, which represent the four directions from which you can view trees: north, east, south, and west.

      iex> tree = %{row: 0, column: 1, height: 2}
      ...> rows_and_cols = AdventOfCode2022.Day8.build_tree_height_map([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
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

  def tree_visible_from_any_direction?(tree, pov), do: Enum.any?(pov, &tree_visible?(tree, &1))

  def tree_visible?(tree, heights, is_visible \\ true)
  def tree_visible?(_, _, false), do: false
  def tree_visible?(_, [], is_visible), do: is_visible
  def tree_visible?(tree, [head | rest], _), do: tree_visible?(tree, rest, tree.height > head)

  def calculate_scenic_score(distances), do: Enum.reduce(distances, fn x, acc -> x * acc end)

  def calculate_viewing_distances(tree, pov) do
    Enum.map(pov, &calculate_viewing_distance(tree, &1))
  end

  def calculate_viewing_distance(tree, heights, distance \\ 0)
  def calculate_viewing_distance(_, [], distance), do: distance

  def calculate_viewing_distance(tree, [head | rest], distance) do
    if tree.height > head do
      calculate_viewing_distance(tree, rest, distance + 1)
    else
      distance + 1
    end
  end
end
