defmodule AdventOfCode2022.Day10 do
  use AdventOfCode2022.Solution

  @first_cycle 1
  @initial_register_value 1
  @crt_width 40

  @type instruction :: :noop | {:addx, integer()} | {:end, {:addx, integer()}}
  @type cycle :: integer()
  @type register_value :: integer()
  @type acc :: any()

  def part_one() do
    read_lines!(trim: true)
    |> parse_into_instructions()
    |> execute(0, &sum_signal/3)
  end

  def part_two() do
    read_lines!(trim: true)
    |> parse_into_instructions()
    |> execute([], &reverse_draw/3)
    |> Enum.reverse()
    |> render_image()
  end

  @spec execute([instruction()], acc(), (cycle(), register_value(), acc() -> acc())) :: acc()
  def execute(instructions, acc, fun) do
    execute(instructions, @first_cycle, @initial_register_value, acc, fun)
  end

  def execute([], _, _, acc, _), do: acc

  def execute([curr | next], cycle, register, acc, fun) do
    case curr do
      {:addx, _} ->
        execute([{:end, curr} | next], cycle + 1, register, fun.(cycle, register, acc), fun)

      {:end, {:addx, v}} ->
        execute(next, cycle + 1, register + v, fun.(cycle, register, acc), fun)

      :noop ->
        execute(next, cycle + 1, register, fun.(cycle, register, acc), fun)
    end
  end

  def sum_signal(cycle, register, acc) do
    if interesting_cycle?(cycle) do
      cycle * register + acc
    else
      acc
    end
  end

  def interesting_cycle?(cycle), do: Enum.member?([20, 60, 100, 140, 180, 220], cycle)

  @doc "Draws the pixels in reverse for performance (i.e. it's faster to prepend an element to a list than add it to the end)."
  def reverse_draw(cycle, register, acc) do
    if sprite_visible?(cycle, register) do
      ["#" | acc]
    else
      ["." | acc]
    end
  end

  def sprite_visible?(cycle, register) do
    Enum.member?(position_sprite(register), position_pixel(cycle))
  end

  def position_pixel(cycle), do: rem(cycle - 1, @crt_width)
  def position_sprite(register), do: Range.new(register - 1, register + 1)

  def render_image(pixels) do
    pixels
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()

    "peep the terminal output above for the answer :)"
  end

  @doc ~S"""
      iex> input = ~S\"""
      ...> noop
      ...> addx 3
      ...> addx -5
      ...> \"""
      ...> AdventOfCode2022.Day10.parse_into_instructions(String.split(input, "\n", trim: true))
      [:noop, {:addx, 3}, {:addx, -5}]
  """
  def parse_into_instructions(input_lines), do: Enum.map(input_lines, &parse_into_instruction/1)

  @spec parse_into_instruction(String.t()) :: instruction()
  def parse_into_instruction("noop"), do: :noop

  def parse_into_instruction(input_line) do
    case String.split(input_line, " ", trim: true) do
      ["addx", v] -> {:addx, String.to_integer(v)}
    end
  end
end
