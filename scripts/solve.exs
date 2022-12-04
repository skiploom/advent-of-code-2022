# Outputs the answers to the given day's puzzles, based on your (hopefully correct!) solution functions
args =
  case System.argv() do
    [] ->
      raise "Please pass in Advent Of Code 2022 day numbers, space-delimited."

    day_numbers ->
      day_numbers
  end

Enum.each(args, &IO.inspect(AdventOfCode2022.answer(&1), label: "🌈 Day #{&1}"))
