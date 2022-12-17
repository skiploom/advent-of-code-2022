defmodule AdventOfCode2022.Day14 do
  use AdventOfCode2022.Solution

  @sand_source {500, 0}
  @cave_floor_offset 2

  @type x_coordinate :: integer()
  @type y_coordinate :: integer()
  @type position :: {x_coordinate(), y_coordinate()}
  @type tile :: :rock | :air | :sand
  @type cave :: %{position() => tile()}
  @type constants :: %{
          required(:sand_source) => position(),
          required(:leftmost_rock) => x_coordinate(),
          required(:rightmost_rock) => x_coordinate(),
          required(:lowest_rock) => y_coordinate(),
          required(:cave_floor) => y_coordinate()
        }
  @type state :: %{required(:constants) => constants(), required(:cave) => cave()}
  @type simulation_opts :: %{
          required(:terminate_fun) => (state(), position() -> boolean()),
          required(:validate_move_fun) => (state(), position() -> boolean()),
          required(:overflow_fun) => (state(), position() -> state())
        }

  def part_one() do
    opts = %{
      terminate_fun: &falling_into_abyss?/2,
      validate_move_fun: &can_move_within_rocky_area?/2,
      overflow_fun: fn state, _ -> state end
    }

    read_lines!(trim: true)
    |> parse_into_state()
    |> simulate_while(opts)
  end

  def part_two() do
    opts = %{
      terminate_fun: &sand_source_blocked?/2,
      validate_move_fun: &can_move_within_cave?/2,
      overflow_fun: &maybe_add_new_column/2
    }

    read_lines!(trim: true)
    |> parse_into_state()
    |> simulate_while(opts)
  end

  def simulate_while(state, opts) do
    simulate_while(state, opts, 0)
  end

  def simulate_while(state, opts, resting_sand_count) do
    case drop_sand(state, state.constants.sand_source, opts) do
      :finish_simulation -> resting_sand_count
      new_state -> simulate_while(new_state, opts, resting_sand_count + 1)
    end
  end

  @spec drop_sand(state(), position(), simulation_opts()) :: position()
  def drop_sand(state, position, opts) do
    rest_position = find_rest_position(state, position, opts)

    if opts.terminate_fun.(state, rest_position) do
      :finish_simulation
    else
      rest_sand(opts.overflow_fun.(state, rest_position), rest_position)
    end
  end

  @spec find_rest_position(state(), position(), simulation_opts()) :: position()
  def find_rest_position(state, p, opts) do
    cond do
      opts.validate_move_fun.(state, down(p)) ->
        find_rest_position(state, down(p), opts)

      opts.validate_move_fun.(state, down_left(p)) ->
        find_rest_position(state, down_left(p), opts)

      opts.validate_move_fun.(state, down_right(p)) ->
        find_rest_position(state, down_right(p), opts)

      true ->
        p
    end
  end

  @spec rest_sand(state(), position()) :: state()
  def rest_sand(%{cave: cave} = state, position) do
    %{state | cave: Map.put(cave, position, sand())}
  end

  def down({x, y}), do: {x, y + 1}
  def down_left({x, y}), do: {x - 1, y + 1}
  def down_right({x, y}), do: {x + 1, y + 1}

  def falling_into_abyss?(state, p) do
    [down(p), down_left(p), down_right(p)]
    |> Enum.any?(fn position_below ->
      not within_horizontal_bounds?(state, position_below) or not blocked?(state, position_below)
    end)
  end

  def sand_source_blocked?(state, position) do
    state.constants.sand_source == position and blocked?(state, position)
  end

  def can_move_within_rocky_area?(state, position) do
    within_rocky_area?(state, position) and not blocked?(state, position)
  end

  def blocked?(state, position), do: state.cave[position] in [:rock, :sand]

  def within_rocky_area?(state, position) do
    within_horizontal_bounds?(state, position) and above_lowest_rock?(state, position)
  end

  def above_lowest_rock?(state, {_x, y}), do: y < state.constants.lowest_rock

  def within_horizontal_bounds?(state, {x, _y}) do
    x >= state.constants.leftmost_rock and x <= state.constants.rightmost_rock
  end

  def can_move_within_cave?(state, position) do
    above_cave_floor?(state, position) and not blocked?(state, position)
  end

  def above_cave_floor?(state, {_x, y}), do: y < state.constants.cave_floor

  def maybe_add_new_column(state, position) do
    if Map.has_key?(state.cave, position) do
      state
    else
      add_new_column(state, position)
    end
  end

  def add_new_column(state, {x, _y}) do
    air_range = Range.new(0, state.constants.cave_floor - 1)
    airs = Enum.map(air_range, fn y -> {{x, y}, air()} end)
    rocky_floor = {{x, state.constants.cave_floor}, rock()}
    column = Map.new([rocky_floor | airs])

    %{state | cave: Map.merge(column, state.cave)}
  end

  def rock(), do: :rock
  def air(), do: :air
  def sand(), do: :sand

  # Parsing functions
  def parse_into_state(input_lines) do
    rocks = parse_into_rocks(input_lines)

    {leftmost_rock, rightmost_rock} = Enum.min_max_by(rocks, fn {x, _y} -> x end)
    lowest_rock = Enum.max_by(rocks, fn {_x, y} -> y end)

    {{leftmost_rock, _}, {rightmost_rock, _}, {_, lowest_rock}} =
      {leftmost_rock, rightmost_rock, lowest_rock}

    cave_floor = lowest_rock + @cave_floor_offset

    %{
      constants: %{
        sand_source: @sand_source,
        leftmost_rock: leftmost_rock,
        rightmost_rock: rightmost_rock,
        lowest_rock: lowest_rock,
        cave_floor: cave_floor
      },
      cave: build_cave(rocks, leftmost_rock, rightmost_rock, lowest_rock, cave_floor)
    }
  end

  def build_cave(rocks, leftmost_rock, rightmost_rock, lowest_rock, cave_floor) do
    info = %{
      rock_set: MapSet.new(rocks),
      left: leftmost_rock,
      right: rightmost_rock,
      lowest_rock: lowest_rock,
      floor: cave_floor
    }

    cave(info, leftmost_rock, 0, %{})
    |> add_floor(leftmost_rock, rightmost_rock, cave_floor)
  end

  def cave(%{lowest_rock: low}, _, y, acc) when low == y - 1, do: acc

  def cave(%{right: right} = info, x, y, acc) when right == x - 1 do
    cave(info, info.left, y + 1, acc)
  end

  def cave(info, x, y, acc) do
    space = if MapSet.member?(info.rock_set, {x, y}), do: rock(), else: air()
    new_acc = Map.put_new(acc, {x, y}, space)

    cave(info, x + 1, y, new_acc)
  end

  def add_floor(cave, left, right, floor) do
    air_row = Map.new(Enum.map(left..right, fn x -> {{x, floor - 1}, air()} end))
    floor_row = Map.new(Enum.map(left..right, fn x -> {{x, floor}, rock()} end))

    cave
    |> Map.merge(air_row)
    |> Map.merge(floor_row)
  end

  def parse_into_rocks(input_lines) do
    input_lines
    |> parse_into_paths()
    |> List.flatten()
  end

  def parse_into_paths(input_lines) do
    Enum.map(input_lines, &String.split(&1, " -> ", trim: true))
    |> Enum.map(&Enum.map(&1, fn str -> coord(str) end))
    |> Enum.map(&parse_into_path(&1, []))
  end

  def coord(str) do
    [x_str, y_str] = String.split(str, ",", trim: true)
    {String.to_integer(x_str), String.to_integer(y_str)}
  end

  def parse_into_path([first, second], lines), do: [line(first, second) | lines]

  def parse_into_path([first, second, third | rest], lines) do
    parse_into_path([second, third | rest], [line(first, second) | lines])
  end

  def line({x, _y0} = start, {x, _y1} = goal), do: vertical_line(start, goal)
  def line({_x0, y} = start, {_x1, y} = goal), do: horizontal_line(start, goal)

  def vertical_line({x, y0}, {x, y1}) do
    Enum.reduce(y0..y1, [], fn row, coords ->
      [{x, row} | coords]
    end)
  end

  def horizontal_line({x0, y}, {x1, y}) do
    Enum.reduce(x0..x1, [], fn col, coords ->
      [{col, y} | coords]
    end)
  end
end
