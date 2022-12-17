defmodule AdventOfCode2022.Day15 do
  use AdventOfCode2022.Solution

  @row 2_000_000

  @type position :: {integer(), integer()}
  @type pair :: {sensor :: position(), beacon :: position}
  @type spot :: :sensor | :beacon | :empty | :unknown
  @type tunnel_map :: %{position() => spot()}

  def part_one(), do: part_one(read_lines!(trim: true), @row)

  def part_one(input_lines, row) do
    input_lines
    |> parse_into_tunnel_map()
    |> count_number_of_non_beacons(row)
  end

  def part_two() do
  end

  def count_number_of_non_beacons(tunnel_map, row) do
    Enum.count(tunnel_map, fn {{_x, y}, spot} -> y == row and spot == :empty end)
  end

  # Parsing functions

  def parse_into_tunnel_map(input_lines) do
    draw_map(parse_into_pairs(input_lines))
  end

  def parse_into_pairs(input_lines), do: Enum.map(input_lines, &parse_into_pair/1)

  def parse_into_pair(input_line) do
    pattern =
      ~r/Sensor at x=(?<xs>-?[0-9]*), y=(?<ys>-?[0-9]*): closest beacon is at x=(?<xb>-?[0-9]*), y=(?<yb>-?[0-9]*)/

    [sensor_x, sensor_y, beacon_x, beacon_y] =
      Enum.map(Regex.run(pattern, input_line, capture: :all_but_first), &String.to_integer/1)

    {{sensor_x, sensor_y}, {beacon_x, beacon_y}}
  end

  def draw_map(pairs) do
    non_beacons = Enum.uniq(Enum.flat_map(pairs, &identify_non_beacon/1))
    {sensors, beacons} = Enum.unzip(pairs)

    init_map(non_beacons ++ sensors ++ beacons)
    |> put_in_tunnel_map(non_beacons, :empty)
    |> put_in_tunnel_map(sensors, :sensor)
    |> put_in_tunnel_map(beacons, :beacon)
  end

  def put_in_tunnel_map(acc, [], _), do: acc

  def put_in_tunnel_map(acc, [position | rest], spot) do
    put_in_tunnel_map(Map.put(acc, position, spot), rest, spot)
  end

  @doc "Returns a map of m * n positions, where values are initialized to :unknown"
  def init_map(known_positions) do
    {{left, _}, {right, _}} = Enum.min_max_by(known_positions, fn {x, _} -> x end)
    {{_, top}, {_, bottom}} = Enum.min_max_by(known_positions, fn {_, y} -> y end)

    positions =
      Enum.reduce(top..bottom, [], fn y, acc ->
        Enum.map(left..right, fn x -> {x, y} end) ++ acc
      end)

    Map.new(positions, fn position -> {position, :unknown} end)
  end

  @doc "Returns the positions surrounding a sensor that cannot be a beacon"
  @spec identify_non_beacon(pair()) :: [position()]
  def identify_non_beacon({sensor, beacon} = pair) do
    distance = calculate_distance(pair)
    positions_around_sensor = get_positions_around(sensor, distance)

    positions_around_sensor -- [beacon]
  end

  @doc "Calculates the [Manhattan distance](https://en.wikipedia.org/wiki/Taxicab_geometry) between two points"
  def calculate_distance({sensor, beacon}), do: calculate_distance(sensor, beacon)
  def calculate_distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  @spec get_positions_around(position(), integer()) :: [position()]
  def get_positions_around(origin, distance), do: get_positions_around(origin, distance, 1, [])

  def get_positions_around({x, y} = origin, d_total, d_curr, acc) when d_total >= d_curr do
    new_acc =
      acc
      |> upper_right(origin, {x, y + d_curr})
      |> lower_right(origin, {x + d_curr, y})
      |> lower_left(origin, {x, y - d_curr})
      |> upper_left(origin, {x - d_curr, y})

    get_positions_around(origin, d_total, d_curr + 1, new_acc)
  end

  def get_positions_around(_, _, _, acc), do: acc

  def upper_right(acc, {_, y}, {_, y}), do: acc
  def upper_right(acc, o, {x, y}), do: upper_right([{x, y} | acc], o, {x + 1, y - 1})

  def lower_right(acc, {x, _}, {x, _}), do: acc
  def lower_right(acc, o, {x, y}), do: lower_right([{x, y} | acc], o, {x - 1, y - 1})

  def lower_left(acc, {_, y}, {_, y}), do: acc
  def lower_left(acc, o, {x, y}), do: lower_left([{x, y} | acc], o, {x - 1, y + 1})

  def upper_left(acc, {x, _}, {x, _}), do: acc
  def upper_left(acc, o, {x, y}), do: upper_left([{x, y} | acc], o, {x + 1, y + 1})
end
