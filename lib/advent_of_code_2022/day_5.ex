defmodule AdventOfCode2022.Day5 do
  use AdventOfCode2022.Solution

  @type crate :: String.t()
  @type stack :: [crate()]
  @type stacks :: %{(stack_number :: integer()) => stack()}
  @type step :: %{
          required(:move) => integer(),
          required(:from) => integer(),
          required(:to) => integer()
        }
  @type procedure :: [step()]

  @step_prefix "move"

  def part_one() do
    {stacks, procedure} = parse_into_stacks_and_procedure(read_lines!(trim: true))
    rearranged_stacks = rearrange(procedure, stacks, &move_one_at_a_time/2)
    generate_message(rearranged_stacks)
  end

  def part_two() do
    {stacks, procedure} = parse_into_stacks_and_procedure(read_lines!(trim: true))
    rearranged_stacks = rearrange(procedure, stacks, &move_all_at_once/2)
    generate_message(rearranged_stacks)
  end

  def generate_message(stacks), do: Enum.join(get_tops(stacks))

  def get_tops(stacks) do
    stacks
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.map(fn {_k, v} -> hd(v) end)
  end

  @spec rearrange(procedure(), stacks(), move_fun :: (stacks(), step() -> stacks())) :: stacks()
  def rearrange([], stacks, _), do: stacks

  def rearrange([current_step | next_steps], stacks, move_function) do
    rearrange(next_steps, move_function.(stacks, current_step), move_function)
  end

  def move_one_at_a_time(stacks, %{move: 0}), do: stacks

  def move_one_at_a_time(stacks, %{move: num_crates, from: source, to: destination} = step) do
    [crate_to_move | remaining_stack] = Map.get(stacks, source)

    move_one_at_a_time(
      %{
        stacks
        | source => remaining_stack,
          destination => [crate_to_move | stacks[destination]]
      },
      %{step | move: num_crates - 1}
    )
  end

  def move_all_at_once(stacks, %{move: num_crates, from: source, to: destination}) do
    crates_to_move = Enum.take(Map.get(stacks, source), num_crates)

    %{
      stacks
      | source => stacks[source] -- crates_to_move,
        destination => crates_to_move ++ stacks[destination]
    }
  end

  @doc ~S"""
  Parses the input strings into a two-element tuple,
  where the first element is a map that illustrates the starting stacks of crates,
  and the second element is a list of rearrangement steps.

      iex> input = [
      ...> "[A]    ",
      ...> "[B] [C]",
      ...> " 1   2 ",
      ...> "move 1 from 1 to 2",
      ...> "move 2 from 2 to 1"
      ...> ]
      ...>
      ...> AdventOfCode2022.Day5.parse_into_stacks_and_procedure(input)
      {%{1 => ["A", "B"], 2 => ["C"]}, [%{move: 1, from: 1, to: 2}, %{move: 2, from: 2, to: 1}]}
  """
  def parse_into_stacks_and_procedure(lines) do
    {stack_lines, procedure_lines} =
      Enum.split_with(lines, &(not String.starts_with?(&1, @step_prefix)))

    {build_stacks(stack_lines), build_steps(procedure_lines)}
  end

  @doc ~S"""
      iex> stack_lines = [
      ...> "[A]    ",
      ...> "[B] [C]",
      ...> " 1   2 "
      ...> ]
      ...>
      ...> AdventOfCode2022.Day5.build_stacks(stack_lines)
      %{1 => ["A", "B"], 2 => ["C"]}
  """
  def build_stacks(stack_lines) do
    [num_stacks_line | crate_lines] = Enum.reverse(stack_lines)
    num_stacks = get_number_of_stacks(num_stacks_line)
    find_crates_pattern = Regex.compile!(build_pattern_str(num_stacks))
    find_crates_function = &find_crates(&1, find_crates_pattern)

    build_stacks(
      crate_lines,
      find_crates_function,
      Map.new(1..num_stacks, fn stack_number -> {stack_number, []} end)
    )
  end

  @spec build_stacks(
          crate_lines :: [String.t()],
          find_crates_fun :: (crate_line :: String.t() -> %{(stack_num :: integer()) => crate()}),
          acc :: stacks()
        ) :: stacks
  def build_stacks([], _, acc), do: acc

  def build_stacks([curr | next], finder, acc) do
    build_stacks(next, finder, push_crates_to_stacks(acc, finder.(curr)))
  end

  @spec push_crates_to_stacks(stacks(), %{(stack_num :: integer()) => crate()}) :: stacks()
  def push_crates_to_stacks(stacks, crates), do: Map.merge(crates, stacks, &push_crate_to_stack/3)

  def push_crate_to_stack(_stack_number, " ", stack), do: stack
  def push_crate_to_stack(_stack_number, crate, stack), do: [crate | stack]

  def get_number_of_stacks(str) do
    Enum.max(Enum.map(String.split(str, " ", trim: true), &String.to_integer/1))
  end

  def find_crates(crate_line, pattern) do
    Map.new(Regex.named_captures(pattern, crate_line), &clean_key/1)
  end

  # Only used when parsing crate lines into stacks, because regex named capture groups must start with a string.
  defp stack_prefix(), do: "stack"
  defp clean_key({k, v}), do: {String.to_integer(String.replace_prefix(k, stack_prefix(), "")), v}

  def crate_pattern_str(n), do: "\\W(?<#{stack_prefix()}#{n}>.)\\W"

  def build_pattern_str(1), do: crate_pattern_str(1)

  def build_pattern_str(num_stacks) when num_stacks > 1 do
    Enum.reduce(2..num_stacks, build_pattern_str(1), fn n, acc ->
      acc <> "\\s" <> crate_pattern_str(n)
    end)
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day5.build_steps(["move 1 from 1 to 2", "move 2 from 2 to 1"])
      [%{move: 1, from: 1, to: 2}, %{move: 2, from: 2, to: 1}]
  """
  def build_steps(procedure_lines), do: Enum.map(procedure_lines, &build_step/1)

  def build_step(procedure_line) do
    [_move, num_crates, _from, source, _to, destination] = String.split(procedure_line, " ")

    %{
      move: String.to_integer(num_crates),
      from: String.to_integer(source),
      to: String.to_integer(destination)
    }
  end
end
