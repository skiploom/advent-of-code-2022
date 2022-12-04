# Outputs the answers to the given day's puzzles, based on your (hopefully correct!) solution functions
arg =
  case System.argv() do
    [day_number | _] ->
      day_number

    [] ->
      raise "Please pass in the Advent Of Code 2022 day number."
  end

IO.inspect AdventOfCode2022.answer(arg)
