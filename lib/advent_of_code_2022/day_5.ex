defmodule AdventOfCode2022.Day5 do
  use AdventOfCode2022.Solution

  @rearrangement_prefix "move"

  def part_one() do
    {crates, procedure} = parse_into_crates_and_rearrangement_procedure(read_lines!(trim: true))

    stacks = build_crate_stacks(crates)
    moves = Enum.map(procedure, &build_move/1)
    reassigned_stacks = rearrange(moves, stacks)

    generate_message(reassigned_stacks)
  end

  def part_two() do
    {crates, procedure} = parse_into_crates_and_rearrangement_procedure(read_lines!(trim: true))

    stacks = build_crate_stacks(crates)
    moves = Enum.map(procedure, &build_move/1)
    reassigned_stacks = rearrange9001(moves, stacks)

    generate_message(reassigned_stacks)
  end

  def generate_message(stacks), do: Enum.join(get_tops(stacks))

  def get_tops(stacks) do
    stacks
    |> Enum.sort_by(fn {k, _v} -> key_to_num(k) end)
    |> Enum.map(fn {_k, v} -> hd(v) end)
  end

  def key_to_num(str), do: String.to_integer(String.replace_prefix(str, "stack", ""))

  @doc ~S"""
      iex> moves = [%{move: 1, from: 1, to: 2}, %{move: 2, from: 2, to: 1}]
      ...> stacks = %{"stack1" => ["A", "B"], "stack2" => ["C"]}
      ...> AdventOfCode2022.Day5.rearrange(moves, stacks)
      %{"stack1" => ["C", "A", "B"], "stack2" => []}
  """
  def rearrange([], stacks), do: stacks

  def rearrange([curr | rest] = _moves, stacks) do
    rearrange(rest, do_move(curr, stacks))
  end

  def do_move(%{move: num_crates, from: source, to: destination}, stacks) do
    source_stack = Map.get(stacks, "stack#{source}")
    destination_stack = Map.get(stacks, "stack#{destination}")

    {new_source, new_destination} =
      Enum.reduce(1..num_crates, {source_stack, destination_stack}, fn _n, {s, d} ->
        [popped_crate | remaining_source_stack] = s
        {remaining_source_stack, [popped_crate | d]}
      end)

    stacks
    |> Map.put("stack#{source}", new_source)
    |> Map.put("stack#{destination}", new_destination)
  end

  @doc ~S"""
      iex> moves = [%{move: 1, from: 1, to: 2}, %{move: 2, from: 2, to: 1}]
      ...> stacks = %{"stack1" => ["A", "B"], "stack2" => ["C"]}
      ...> AdventOfCode2022.Day5.rearrange9001(moves, stacks)
      %{"stack1" => ["A", "C", "B"], "stack2" => []}
  """
  def rearrange9001([], stacks), do: stacks

  def rearrange9001([curr | rest] = _moves, stacks) do
    rearrange9001(rest, do_move9001(curr, stacks))
  end

  def do_move9001(%{move: num_crates, from: source, to: destination}, stacks) do
    source_stack = Map.get(stacks, "stack#{source}")
    destination_stack = Map.get(stacks, "stack#{destination}")

    temp_stack = Enum.take(source_stack, num_crates)

    {new_source, new_destination} = {source_stack -- temp_stack, temp_stack ++ destination_stack}

    stacks
    |> Map.put("stack#{source}", new_source)
    |> Map.put("stack#{destination}", new_destination)
  end

  @doc ~S"""
      iex> crate_strings = [
      ...> "[A]    ",
      ...> "[B] [C]",
      ...> " 1   2 "
      ...> ]
      ...>
      ...> AdventOfCode2022.Day5.build_crate_stacks(crate_strings)
      %{"stack1" => ["A", "B"], "stack2" => ["C"]}
  """
  def build_crate_stacks(crate_strings) do
    [num_stacks_line | crate_lines] = Enum.reverse(crate_strings)
    num_stacks = get_number_of_stacks(num_stacks_line)
    pattern = Regex.compile!(build_pattern(num_stacks))

    init_map = Map.new(1..num_stacks, fn n -> {"stack#{n}", []} end)

    Enum.reduce(crate_lines, init_map, fn crate_line, acc ->
      Map.merge(Regex.named_captures(pattern, crate_line), acc, fn _k, v, v_acc ->
        case v do
          " " -> v_acc
          crate -> [crate | v_acc]
        end
      end)
    end)
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day5.build_move("move 1 from 1 to 2")
      %{move: 1, from: 1, to: 2}
  """
  def build_move(step) do
    [_move, num_crates, _from, source, _to, destination] = String.split(step, " ")

    %{
      move: String.to_integer(num_crates),
      from: String.to_integer(source),
      to: String.to_integer(destination)
    }
  end

  def get_number_of_stacks(str) do
    Enum.max(Enum.map(String.split(str, " ", trim: true), &String.to_integer/1))
  end

  def crate_pattern_str(n), do: "\\W(?<stack#{n}>.)\\W"

  def build_pattern(1), do: crate_pattern_str(1)

  def build_pattern(num_stacks) when num_stacks > 1 do
    Enum.reduce(2..num_stacks, build_pattern(1), fn n, acc ->
      acc <> "\\s" <> crate_pattern_str(n)
    end)
  end

  @doc ~S"""
  Parses the input strings into a two-element tuple,
  where the first element is a list that illustrates the starting stacks of crates,
  and the second element is a list of rearrangement directions.

      iex> input = [
      ...> "[A]    ",
      ...> "[B] [C]",
      ...> " 1   2 ",
      ...> "move 1 from 1 to 2",
      ...> "move 2 from 2 to 1"
      ...> ]
      ...>
      ...> AdventOfCode2022.Day5.parse_into_crates_and_rearrangement_procedure(input)
      {["[A]    ", "[B] [C]", " 1   2 "], ["move 1 from 1 to 2", "move 2 from 2 to 1"]}
  """
  def parse_into_crates_and_rearrangement_procedure(lines) do
    Enum.split_with(lines, &(not String.starts_with?(&1, @rearrangement_prefix)))
  end
end
