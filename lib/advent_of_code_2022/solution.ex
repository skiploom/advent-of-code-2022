defmodule AdventOfCode2022.Solution do
  @type answer :: integer()

  @callback part_one() :: answer()
  @callback part_two() :: answer()

  defmacro __using__(_opts) do
    quote do
      @behaviour AdventOfCode2022.Solution
      import AdventOfCode2022.Solution, only: [read_lines!: 0, read_lines!: 1]
    end
  end

  defmacro read_lines!(split_opts \\ []) do
    day_number =
      __CALLER__.module
      |> Atom.to_string()
      |> String.split(".")
      |> List.last()
      |> String.replace_prefix("Day", "")

    read_lines!(day_number, split_opts)
  end

  @spec read_lines!(day_number :: integer() | String.t(), split_opts :: keyword()) :: [String.t()]
  def read_lines!(d, opts), do: String.split(File.read!("inputs/day_#{d}.txt"), "\n", opts)
end
