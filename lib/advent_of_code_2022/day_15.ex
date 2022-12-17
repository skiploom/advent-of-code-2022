defmodule AdventOfCode2022.Day15 do
  use AdventOfCode2022.Solution

  @row 2_000_000

  def part_one(), do: part_one(read_lines!(trim: true), @row)

  def part_one(input_lines, row) do
    input_lines
    |> parse_into_pairs()
    |> calculate_sensor_beacon_distances()
    |> count_non_beacons(row)
  end

  def part_two() do
  end

  def count_non_beacons(sensor_beacon_distances, row) do
    {leftmost_x, rightmost_x} = get_horizontal_bounds(sensor_beacon_distances)

    row_positions = Enum.map(leftmost_x..rightmost_x, fn x -> {x, row} end)

    Enum.count(row_positions, &not_beacon?(&1, sensor_beacon_distances))
  end

  def not_beacon?(position, sensor_beacon_distances) do
    Enum.any?(sensor_beacon_distances, fn %{sensor: s, beacon: b, distance: d} ->
      position != b and calculate_distance(position, s) <= d
    end)
  end

  def get_horizontal_bounds(sensor_beacon_distances) do
    # Get an arbitrary X-coordinate from the sensors, because apparently nil > any integer.
    %{sensor: {arbitrary_x, _}} = hd(sensor_beacon_distances)
    leftmost_x = min_x(sensor_beacon_distances, arbitrary_x)
    rightmost_x = max_x(sensor_beacon_distances, arbitrary_x)

    {leftmost_x, rightmost_x}
  end

  def min_x([], acc), do: acc

  def min_x([%{sensor: {x, _y}, distance: d} | rest], acc) do
    min_x(rest, min(x - d, acc))
  end

  def max_x([], acc), do: acc

  def max_x([%{sensor: {x, _y}, distance: d} | rest], acc) do
    max_x(rest, max(x + d, acc))
  end

  def calculate_sensor_beacon_distances(pairs) do
    Enum.map(pairs, fn {s, b} -> %{sensor: s, beacon: b, distance: calculate_distance(s, b)} end)
  end

  @doc "Calculates the [Manhattan distance](https://en.wikipedia.org/wiki/Taxicab_geometry) between two points"
  def calculate_distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  # Parsing functions

  def parse_into_pairs(input_lines), do: Enum.map(input_lines, &parse_into_pair/1)

  def parse_into_pair(input_line) do
    pattern =
      ~r/Sensor at x=(?<xs>-?[0-9]*), y=(?<ys>-?[0-9]*): closest beacon is at x=(?<xb>-?[0-9]*), y=(?<yb>-?[0-9]*)/

    [sensor_x, sensor_y, beacon_x, beacon_y] =
      Enum.map(Regex.run(pattern, input_line, capture: :all_but_first), &String.to_integer/1)

    {{sensor_x, sensor_y}, {beacon_x, beacon_y}}
  end
end
