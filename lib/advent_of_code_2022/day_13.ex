defmodule AdventOfCode2022.Day13 do
  use AdventOfCode2022.Solution

  @divider_packet_1 [[2]]
  @divider_packet_2 [[6]]

  @type packet_data :: integer() | [integer()]
  @type packet :: [packet_data()]
  @type pair :: {packet(), packet()}

  def part_one() do
    read_lines!(trim: true)
    |> parse_into_pairs()
    |> sum_correct_indices()
  end

  def part_two() do
    read_lines!(trim: true)
    |> parse_into_packets()
    |> Enum.concat([@divider_packet_1, @divider_packet_2])
    |> Enum.sort(&pair_ordered?/2)
    |> get_decoder_key()
  end

  @spec sum_correct_indices([pair()]) :: integer()
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

  @spec pair_ordered?(left :: packet(), right :: packet()) :: boolean()
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

  @spec compare(left :: packet_data(), right :: packet_data()) :: :lt | :gt | :eq
  def compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :lt
      left > right -> :gt
      left == right -> :eq
    end
  end

  def compare(left, right) when is_list(left) and is_list(right), do: compare_lists(left, right)
  def compare(left, right) when is_integer(left), do: compare_lists([left], right)
  def compare(left, right) when is_integer(right), do: compare_lists(left, [right])

  @spec compare_lists(left :: packet_data(), right :: packet_data()) :: :lt | :gt | :eq
  def compare_lists([], []), do: :eq
  def compare_lists([], [_ | _] = _right_is_nonempty), do: :lt
  def compare_lists([_ | _] = _left_is_nonempty, []), do: :gt

  def compare_lists([left | tail_l], [right | tail_r]) do
    case compare(left, right) do
      :lt -> :lt
      :gt -> :gt
      :eq -> compare_lists(tail_l, tail_r)
    end
  end

  @spec get_decoder_key([packet()]) :: integer()
  def get_decoder_key(packets), do: get_decoder_key(packets, 1, nil, nil)

  def get_decoder_key(_, _, i1, i2) when not (is_nil(i1) or is_nil(i2)), do: i1 * i2

  def get_decoder_key([packet | rest], index, divider1_index, divider2_index) do
    case packet do
      @divider_packet_1 -> get_decoder_key(rest, index + 1, index, divider2_index)
      @divider_packet_2 -> get_decoder_key(rest, index + 1, divider1_index, index)
      _ -> get_decoder_key(rest, index + 1, divider1_index, divider2_index)
    end
  end

  # Parsing functions

  @spec parse_into_pairs([String.t()]) :: [pair()]
  def parse_into_pairs(input_lines) do
    Enum.reverse(parse_into_pairs(input_lines, []))
  end

  def parse_into_pairs([], acc), do: acc

  def parse_into_pairs([left, right | rest], acc) do
    parse_into_pairs(rest, [pair(left, right) | acc])
  end

  # Yes, I am very, very lazy.
  def pair(l, r), do: {packet(l), packet(r)}
  def packet(str), do: Code.string_to_quoted!(str)

  @doc "Unlike parse_into_pairs/1, this will return the packets in reverse order. (Doesn't matter for the puzzle.)"
  @spec parse_into_packets([String.t()]) :: [packet()]
  def parse_into_packets(input_lines), do: parse_into_packets(input_lines, [])

  def parse_into_packets([], acc), do: acc
  def parse_into_packets([line | rest], acc), do: parse_into_packets(rest, [packet(line) | acc])
end
