defmodule AdventOfCode2022.Day12 do
  use AdventOfCode2022.Solution

  @default_start_height "S"
  @default_goal_height "E"

  @type position :: {x :: integer(), y :: integer()}
  @type height :: String.t()
  @type heightmap :: %{required(:position) => height()}
  @type distance :: integer() | :unknown

  @type distance_table :: %{
          required(:position) => %{
            required(:distance) => distance(),
            required(:previous) => position() | :unknown | :none
          }
        }

  @type constants :: %{
          required(:heightmap) => heightmap(),
          required(:start) => position(),
          required(:goal) => position()
        }

  @type acc :: %{
          required(:distance_table) => distance_table(),
          required(:visited) => [position()],
          required(:unvisited) => [position()]
        }

  @type state :: %{required(:constants) => constants, required(:acc) => acc}

  def part_one() do
    read_lines!(trim: true)
    |> parse_into_state()
    |> find_shortest_path()
  end

  def part_two() do
    read_lines!(trim: true)
    |> parse_into_states_with_multiple_starting_points()
    |> Enum.map(&find_shortest_path/1)
    |> Enum.min()
  end

  def find_shortest_path(state) do
    start = start(state)
    starting_state = set_distance(state, start, 0, :none)

    find_shortest_path(starting_state, start)
  end

  @spec find_shortest_path(state(), current :: position()) :: state() | integer()
  def find_shortest_path(state, nil) do
    fetch_distance(state, goal(state))
  end

  def find_shortest_path(s, curr) do
    # My attempt at implementing Dijkstra's.
    state =
      s
      |> maybe_set_distances(curr, find_visitable_neighbors(s, curr))
      |> mark_visited(curr)

    find_shortest_path(state, choose_next_to_visit(state))
  end

  @spec maybe_set_distances(state(), current :: position(), neighbors :: [position()]) :: state()
  def maybe_set_distances(s, curr, neighbors) do
    Enum.reduce(neighbors, s, fn neighbor, acc -> maybe_set_distance(acc, curr, neighbor) end)
  end

  @spec maybe_set_distance(state(), current :: position(), neighbor :: position()) :: state()
  def maybe_set_distance(s, curr, neighbor) do
    calculated_neighbor_distance = fetch_distance(s, curr) + 1
    previously_recorded_neighbor_distance = fetch_distance(s, neighbor)

    if less_or_equal?(calculated_neighbor_distance, previously_recorded_neighbor_distance) do
      set_distance(s, neighbor, calculated_neighbor_distance, curr)
    else
      s
    end
  end

  @spec set_distance(state(), position(), distance(), previous :: position()) :: state()
  def set_distance(s, position, d, prev) do
    set_state(s, :distance_table, position, %{distance: d, previous: prev})
  end

  @spec find_visitable_neighbors(state(), position()) :: [position()]
  def find_visitable_neighbors(state, position) do
    heightmap = heightmap(state)
    current_height = Map.get(heightmap, position)
    neighbors_heights = get_neighbors_heights(heightmap, position)

    filter_visitable(neighbors_heights, current_height)
  end

  @spec get_neighbors_heights(heightmap(), position()) :: %{position() => height()}
  def get_neighbors_heights(heightmap, position) do
    Map.take(heightmap, get_neighbors(position))
  end

  @spec filter_visitable(%{position() => height()}, height()) :: [position()]
  def filter_visitable(neighbors_heights, current_height) do
    neighbors_heights
    |> Enum.filter(fn {_position, height} -> visitable?(current_height, height) end)
    |> Enum.map(fn {position, _height} -> position end)
  end

  def visitable?(current_height, neighbor_height) do
    height_value(current_height) + 1 >= height_value(neighbor_height)
  end

  def height_value(height) do
    Map.get(height_values(), height)
  end

  def height_values() do
    ordered_heights = ~w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
    highest_elevation = length(ordered_heights)

    ordered_heights
    |> Enum.zip(Range.new(1, highest_elevation))
    |> Map.new()
    |> Map.put_new("S", 1)
    |> Map.put_new("E", length(ordered_heights))
  end

  @spec get_neighbors(position()) :: [position()]
  def get_neighbors(p), do: [up(p), right(p), down(p), left(p)]

  def up({x, y}), do: {x, y + 1}
  def right({x, y}), do: {x + 1, y}
  def down({x, y}), do: {x, y - 1}
  def left({x, y}), do: {x - 1, y}

  @spec mark_visited(state(), position()) :: state()
  def mark_visited(state, position) do
    state
    |> add_to_visited(position)
    |> remove_from_unvisited(position)
  end

  @spec add_to_visited(state(), position()) :: state()
  def add_to_visited(s, position) do
    set_state(s, :visited, [position | visited(s)])
  end

  @spec remove_from_unvisited(state(), position()) :: state()
  def remove_from_unvisited(s, position) do
    set_state(s, :unvisited, List.delete(unvisited(s), position))
  end

  @spec choose_next_to_visit(state()) :: position() | nil
  def choose_next_to_visit(%{acc: %{unvisited: []}}), do: nil

  def choose_next_to_visit(s) do
    unvisited_distances = Map.take(distance_table(s), unvisited(s))

    {position, %{distance: distance}} =
      Enum.min(unvisited_distances, fn {_k1, v1}, {_k2, v2} ->
        less_or_equal?(v1.distance, v2.distance)
      end)

    if distance == :unknown do
      nil
    else
      position
    end
  end

  @spec less_or_equal?(distance(), distance()) :: distance()
  def less_or_equal?(d1, d2) do
    # In Dijkstra's algorithm, we assume an unknown distance is infinite
    case {d1, d2} do
      {:unknown, :unknown} -> true
      {:unknown, _} -> false
      {_, :unknown} -> true
      {d1, d2} -> d1 <= d2
    end
  end

  # Getters and setters

  def start(state), do: fetch(state, :start)
  def goal(state), do: fetch(state, :goal)
  def heightmap(state), do: fetch(state, :heightmap)
  def visited(state), do: fetch(state, :visited)
  def unvisited(state), do: fetch(state, :unvisited)
  def distance_table(state), do: fetch(state, :distance_table)

  def fetch_distance(state, position), do: get_in(distance_table(state), [position, :distance])

  def fetch(state, key) do
    case key do
      :start -> get_in(state, [:constants, :start])
      :goal -> get_in(state, [:constants, :goal])
      :heightmap -> get_in(state, [:constants, :heightmap])
      :visited -> get_in(state, [:acc, :visited])
      :unvisited -> get_in(state, [:acc, :unvisited])
      :distance_table -> get_in(state, [:acc, :distance_table])
    end
  end

  def set_state(state, :distance_table, position, value) do
    put_in(state, [:acc, :distance_table, position], value)
  end

  def set_state(state, key, value) do
    case key do
      [:constants, :heightmap, :start, :goal] ->
        raise "Key #{Atom.to_string(key)} should be immutable."

      :acc ->
        IO.inspect(Map.put(state, :acc, value),
          label: "You sure you wanna update the whole acc, broseidon?"
        )

      :distance_table ->
        IO.inspect(put_in(state, [:acc, :distance_table], value),
          label: "Really? Have you seen set_state/4, brah?"
        )

      :visited ->
        put_in(state, [:acc, :visited], value)

      :unvisited ->
        put_in(state, [:acc, :unvisited], value)
    end
  end

  # Input parsing functions

  # Part 1 specific parser
  @spec parse_into_state([String.t()]) :: state()
  def parse_into_state(input_lines) do
    constants = parse_into_constants(input_lines)
    acc = build_acc(constants)

    %{constants: constants, acc: acc}
  end

  @spec parse_into_constants([String.t()]) :: constants()
  def parse_into_constants(input_lines) do
    input_lines
    |> Enum.map(&String.split(&1, "", trim: true))
    |> parse_into_constants(0, 0, %{}, nil, nil)
  end

  def parse_into_constants([], _, _, heightmap, start, goal) do
    %{heightmap: heightmap, start: start, goal: goal}
  end

  def parse_into_constants([[] | cols], row_num, _col_num, heightmap, start, goal) do
    parse_into_constants(cols, row_num + 1, 0, heightmap, start, goal)
  end

  def parse_into_constants([[curr | row] | cols], row_num, col_num, heightmap, start, goal) do
    position = {col_num, row_num}
    height = curr
    heightmap = Map.put_new(heightmap, position, height)

    start = if starting_position?(start, height), do: position, else: start
    goal = if goal_position?(goal, height), do: position, else: goal

    parse_into_constants([row | cols], row_num, col_num + 1, heightmap, start, goal)
  end

  def starting_position?(start, height), do: is_nil(start) and height == @default_start_height
  def goal_position?(goal, height), do: is_nil(goal) and height == @default_goal_height

  @spec build_acc(constants()) :: acc()
  def build_acc(%{heightmap: heightmap}) do
    distance_table = build_distance_table(heightmap)
    visited = []
    unvisited = Map.keys(heightmap)

    %{distance_table: distance_table, visited: visited, unvisited: unvisited}
  end

  def build_distance_table(heightmap) do
    Map.new(heightmap, fn {position, _} -> {position, build_row()} end)
  end

  def build_row(), do: %{distance: :unknown, previous: :unknown}

  # Part 2 specific parser
  def parse_into_states_with_multiple_starting_points(input_lines) do
    # JankyAF algo:
    # 1. Call the Part 1 parser. It'll return a state() with the starting position at height "S".
    # 2. From that state, find all of the positions where height is "a".
    # 3. From that find, there will be SO MANY positions where height is "a" and so many of them
    #    will be either:
    #       a) unviable (i.e. can't even visit a neighbor, because it's surrounded by too-high "c"s)
    #       b) redundant (i.e. its only visitable neighbor is "a", so that will already add an extra step)
    #    So reject those positions from the list of viable a_positions.
    # 4. For those remaining positions, create a list of state()s where start == that position.
    # 5. Return that list.
    state = parse_into_state(input_lines)

    heightmap(state)
    |> find_viable_starting_positions()
    |> Enum.map(fn position -> put_in(state, [:constants, :start], position) end)
  end

  @spec find_viable_starting_positions(heightmap()) :: [position()]
  def find_viable_starting_positions(heightmap) do
    heightmap
    |> Enum.filter(fn {position, _height} -> viable?(heightmap, position) end)
    |> Enum.map(fn {k, _v} -> k end)
  end

  def viable?(heightmap, position) do
    lowest_elevation?(heightmap[position]) and
      neighbors_visitable_and_higher?(heightmap, position)
  end

  def lowest_elevation?(height), do: height in ["S", "a"]

  def neighbors_visitable_and_higher?(heightmap, position) do
    get_neighbors_heights(heightmap, position)
    |> Enum.filter(fn {_position, height} ->
      neighbor_visitable_and_higher?(heightmap[position], height)
    end)
    |> Enum.map(fn {position, _height} -> position end)
  end

  def neighbor_visitable_and_higher?(current_height, neighbor_height) do
    height_value(current_height) + 1 == height_value(neighbor_height)
  end
end
