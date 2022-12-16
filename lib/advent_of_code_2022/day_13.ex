defmodule AdventOfCode2022.Day13 do
  use AdventOfCode2022.Solution

  @type packet_data :: integer() | [integer()]
  @type packet :: [packet_data()]
  @type pair :: {packet(), packet()}

  def part_one() do
    read_lines!(trim: true)
    |> parse_into_pairs()
    |> sum_correct_indices()
  end

  def part_two() do
  end

  def sum_correct_indices(pairs) do
    sum_correct_indices(pairs, 1, 0)
  end

  def sum_correct_indices([], _, acc), do: acc

  def sum_correct_indices([{left, right} | rest], index, acc) do
    new_acc =
      if pair_ordered?(left, right) do
        index + acc
      else
        acc
      end

    sum_correct_indices(rest, index + 1, new_acc)
  end

  def pair_ordered?([], []), do: true
  def pair_ordered?([], [_ | _]), do: true
  def pair_ordered?([_ | _], []), do: false

  def pair_ordered?([left | tail_l], [right | tail_r]) do
    case compare(left, right) do
      :lt -> true
      :gt -> false
      :eq -> pair_ordered?(tail_l, tail_r)
    end
  end

  def compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :lt
      left > right -> :gt
      left == right -> :eq
    end
  end

  def compare(left, right) when is_list(left) and is_list(right) do
    compare_lists(left, right)
  end

  def compare(left, right) do
    cond do
      is_integer(left) ->
        compare_lists([left], right)

      is_integer(right) ->
        compare_lists(left, [right])
    end
  end

  def compare_lists([], []), do: :eq
  def compare_lists([], [_ | _] = _right_is_nonempty), do: :lt
  def compare_lists([_ | _] = _left_is_nonempty, []), do: :gt

  def compare_lists([l | tail_l], [r | tail_r]) when is_integer(l) and is_integer(r) do
    cond do
      l < r -> :lt
      l > r -> :gt
      l == r -> compare_lists(tail_l, tail_r)
    end
  end

  def compare_lists([l | tail_l], [r | tail_r]) when is_list(l) and is_list(r) do
    case compare(l, r) do
      :lt -> :lt
      :gt -> :gt
      :eq -> compare(tail_l, tail_r)
    end
  end

  def compare_lists([l | tail_l], [r | tail_r]) do
    case compare(l, r) do
      :lt -> :lt
      :gt -> :gt
      :eq -> compare_lists(tail_l, tail_r)
    end
  end

  # Parsing functions

  def parse_into_pairs(input_lines) do
    Enum.reverse(parse(input_lines, []))
  end

  def parse([], acc), do: acc

  def parse([left, right | rest], acc) do
    parse(rest, [pair(left, right) | acc])
  end

  # Yes, I am very, very lazy.
  def pair(l, r), do: {Code.string_to_quoted!(l), Code.string_to_quoted!(r)}
end
