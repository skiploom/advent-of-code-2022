defmodule AdventOfCode2022.Day9 do
  use AdventOfCode2022.Solution

  @starting_position {0, 0}

  def part_one() do
    read_lines!(trim: true)
    |> parse_into_motions()
    |> flatten_motions()
    |> move_rope(2)
    |> List.last()
    |> count_visited_positions()
  end

  def part_two() do
    read_lines!(trim: true)
    |> parse_into_motions()
    |> flatten_motions()
    |> move_rope(10)
    |> List.last()
    |> count_visited_positions()
  end

  def count_visited_positions(positions), do: MapSet.size(MapSet.new(positions))

  @doc """
  Given a list of motions and a number of knots, move_rope/2 returns a list of n sublists,
  where n is the number of knots, and each sublist contains the visited positions of each knot,
  assuming:

    1. All knots start at {0, 0}.
    2. The motions describe the positions the head knot (i.e. knot 1) should visit.
    3. Knot k + 1 should never be more than "2 spaces away" from knot k.
    4. The tail knot (i.e. knot n) is the last sublist.

  (Note: Each sublist contains the reversed list of positions visited by its corresponding knot.
  I didn't need the positions ordered correctly to solve the advent puzzle,
  but it would be easy to slap on an Enum.reverse/1 if necessary.)
  """
  def move_rope(motions, num_knots) do
    starting_knots = starting_knot_positions(num_knots)

    {head_visits, non_head_knot_visits} =
      Enum.reduce(motions, starting_knots, fn motion, {head_visits, other_knot_visits} ->
        [curr_head | _] = head_visits
        moved_head = move_head_once(motion, curr_head)

        {[moved_head | head_visits], follow_knot(other_knot_visits, moved_head, [])}
      end)

    [head_visits | non_head_knot_visits]
  end

  def starting_knot_positions(num_knots) do
    {[@starting_position], List.duplicate([@starting_position], num_knots - 1)}
  end

  def follow_knot([], _, acc), do: acc

  def follow_knot([[current_position | _] = visited | trailing_knots], leading_knot, acc) do
    new_position = maybe_move_tail_once(current_position, leading_knot)

    follow_knot(trailing_knots, new_position, append(acc, [new_position | visited]))
  end

  def append([], new), do: [new]
  def append(acc, new), do: acc ++ [new]

  @spec move_head_once(motion :: tuple(), tuple()) :: tuple()
  def move_head_once({:up, _}, {x, y}), do: {x, y + 1}
  def move_head_once({:right, _}, {x, y}), do: {x + 1, y}
  def move_head_once({:down, _}, {x, y}), do: {x, y - 1}
  def move_head_once({:left, _}, {x, y}), do: {x - 1, y}

  @doc ~S"""
      iex> AdventOfCode2022.Day9.maybe_move_tail_once({1, 1}, {1, 1})
      {1, 1}

      iex> AdventOfCode2022.Day9.maybe_move_tail_once({1, 1}, {1, 2})
      {1, 1}

      iex> AdventOfCode2022.Day9.maybe_move_tail_once({1, 1}, {1, 3})
      {1, 2}

      iex> AdventOfCode2022.Day9.maybe_move_tail_once({1, 1}, {-1, 1})
      {0, 1}

      iex> AdventOfCode2022.Day9.maybe_move_tail_once({1, 1}, {3, 3})
      {2, 2}

      iex> AdventOfCode2022.Day9.maybe_move_tail_once({0, 0}, {2, 1})
      {1, 1}

      iex> AdventOfCode2022.Day9.maybe_move_tail_once({3, 1}, {3, 3})
      {3, 2}

      iex> AdventOfCode2022.Day9.maybe_move_tail_once({0, 0}, {1, 0})
      {0, 0}
  """
  @spec maybe_move_tail_once(tuple(), tuple()) :: new_tail_position :: tuple()
  def maybe_move_tail_once({x_tail, y_tail} = tail_position, {x_head, y_head} = head_position) do
    cond do
      overlapping?(tail_position, head_position) ->
        tail_position

      touching?(tail_position, head_position) ->
        tail_position

      same_column?(tail_position, head_position) ->
        if y_head > y_tail, do: {x_tail, y_tail + 1}, else: {x_tail, y_tail - 1}

      same_row?(tail_position, head_position) ->
        if x_head > x_tail, do: {x_tail + 1, y_tail}, else: {x_tail - 1, y_tail}

      true ->
        move_tail_diagonally(tail_position, head_position)
    end
  end

  def overlapping?(tail_position, head_position), do: tail_position == head_position

  def touching?({x_tail, y_tail}, {x_head, y_head}) do
    abs(x_tail - x_head) <= 1 and abs(y_tail - y_head) <= 1
  end

  def same_column?({x_tail, _}, {x_head, _}), do: x_tail == x_head
  def same_row?({_, y_tail}, {_, y_head}), do: y_tail == y_head

  def move_tail_diagonally({x_tail, y_tail}, {x_head, y_head}) do
    case {x_head - x_tail > 0, y_head - y_tail > 0} do
      {true, true} -> {x_tail + 1, y_tail + 1}
      {true, false} -> {x_tail + 1, y_tail - 1}
      {false, false} -> {x_tail - 1, y_tail - 1}
      {false, true} -> {x_tail - 1, y_tail + 1}
    end
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day9.parse_into_motions(["U 2", "D 2", "L 1", "R 4"])
      [{:up, 2}, {:down, 2}, {:left, 1}, {:right, 4}]
  """
  def parse_into_motions(input_lines), do: Enum.map(input_lines, &parse_into_motion/1)

  def parse_into_motion(input_line) do
    case String.split(input_line, " ", trim: true) do
      ["U", steps] -> {:up, String.to_integer(steps)}
      ["R", steps] -> {:right, String.to_integer(steps)}
      ["D", steps] -> {:down, String.to_integer(steps)}
      ["L", steps] -> {:left, String.to_integer(steps)}
    end
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day9.flatten_motions([{:up, 2}, {:down, 2}])
      [{:up, 1}, {:up, 1}, {:down, 1}, {:down, 1}]
  """
  def flatten_motions(motions) do
    Enum.flat_map(motions, fn {direction, steps} ->
      List.duplicate({direction, 1}, steps)
    end)
  end
end
