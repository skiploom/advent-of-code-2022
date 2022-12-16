defmodule AdventOfCode2022.Day11.Monkey do
  @enforce_keys ~w(name items operation test true_recipient false_recipient inspect_count)a
  defstruct @enforce_keys

  @type t :: %__MODULE__{}
end

defmodule AdventOfCode2022.Day11 do
  use AdventOfCode2022.Solution
  alias __MODULE__.Monkey

  def part_one() do
    read_lines!()
    |> parse_into_monkeys()
    |> build_monkeys_map()
    |> simulate_rounds(20, &monkey_do/2)
    |> get_two_most_active_monkeys()
    |> calculate_monkey_business()
  end

  def part_two() do
    # I haven't completed part 2 yet. :(
    # I know it involves modulo stuff in some fashion.
  end

  def calculate_monkey_business(monkeys) do
    Enum.reduce(monkeys, 1, fn m, acc -> m.inspect_count * acc end)
  end

  def get_two_most_active_monkeys(monkeys_map) do
    monkeys_map
    |> Map.values()
    |> Enum.sort_by(& &1.inspect_count, :desc)
    |> Enum.take(2)
  end

  def simulate_rounds(monkeys_map, num_rounds, monkey_do_fun) do
    num_monkeys = map_size(monkeys_map)

    Enum.reduce(1..num_rounds, monkeys_map, fn _round, acc ->
      simulate_round(acc, monkey_do_fun, Enum.to_list(0..(num_monkeys - 1)))
    end)
  end

  def simulate_round(monkeys_map, _, []), do: monkeys_map

  def simulate_round(monkeys_map, fun, [current_turn | next]) do
    throwing_monkey = Map.get(monkeys_map, current_turn)
    simulate_round(fun.(monkeys_map, throwing_monkey), fun, next)
  end

  def monkey_do(monkeys_map, %{items: []}), do: monkeys_map

  def monkey_do(monkeys_map, %{items: [curr | _]} = monkey) do
    {monkey, curr} = monkey_see(monkey, curr)
    monkeys_map = Map.put(monkeys_map, monkey.name, monkey)
    new_worry_level = bore_monkey(curr)
    recipient_name = monkey_befriend(monkey, new_worry_level)
    monkey_do(fling(monkeys_map, monkey.name, recipient_name, new_worry_level), drop_item(monkey))
  end

  def monkey_see(%{operation: op, inspect_count: count} = monkey, worry_level) do
    {%{monkey | inspect_count: count + 1}, op.(worry_level)}
  end

  def bore_monkey(worry_level), do: floor(worry_level / 3)

  def monkey_befriend(monkey, worry_level) do
    if rem(worry_level, monkey.test) == 0 do
      monkey.true_recipient
    else
      monkey.false_recipient
    end
  end

  def fling(monkeys_map, source_monkey, destination_monkey, item) do
    monkeys_map
    |> Map.update!(source_monkey, &drop_item/1)
    |> Map.update!(destination_monkey, &receive_item(&1, item))
  end

  def drop_item(%{items: [_curr | rest]} = monkey) do
    %{monkey | items: rest}
  end

  def receive_item(%{items: items} = monkey, new_item) do
    %{monkey | items: items ++ [new_item]}
  end

  @spec build_monkeys_map([Monkey.t()]) :: %{integer() => Monkey.t()}
  def build_monkeys_map(monkeys), do: Map.new(monkeys, &{&1.name, &1})

  def parse_into_monkeys(input_lines) do
    parse_into_monkeys(input_lines, %{}, [])
  end

  @spec parse_into_monkeys([String.t()], map() | Monkey.t(), [Monkey.t()]) :: [Monkey.t()]
  def parse_into_monkeys([], _, reversed_monkeys), do: Enum.reverse(reversed_monkeys)

  def parse_into_monkeys([_empty_line | next], %Monkey{} = parsed_monkey, monkeys) do
    parse_into_monkeys(next, %{}, [parsed_monkey | monkeys])
  end

  def parse_into_monkeys([curr | next], monkey_map, monkeys) do
    parse_into_monkeys(next, build_monkey(monkey_map, curr), monkeys)
  end

  def build_monkey(map, input_line) do
    {key, value} = parse_into_monkey_attr(input_line)
    maybe_finish_monkey(Map.put(map, key, value))
  end

  def maybe_finish_monkey(map) when map_size(map) == 6 do
    struct(Monkey, Map.put(map, :inspect_count, 0))
  end

  def maybe_finish_monkey(map), do: map

  def parse_into_monkey_attr(input_line) do
    case String.split(String.replace(input_line, [":", ","], ""), " ", trim: true) do
      ["Monkey", name] -> {:name, String.to_integer(name)}
      ["Starting", "items" | items] -> {:items, parse_into_items(items)}
      ["Operation", "new", "=", "old", op, term] -> {:operation, parse_into_operation(op, term)}
      ["Test" | divisible_by] -> {:test, String.to_integer(List.last(divisible_by))}
      ["If", "true" | recipient] -> {:true_recipient, String.to_integer(List.last(recipient))}
      ["If", "false" | recipient] -> {:false_recipient, String.to_integer(List.last(recipient))}
    end
  end

  def parse_into_items(strs), do: Enum.map(strs, &String.to_integer/1)

  def parse_into_operation(op, term) do
    case {op, term} do
      {"*", "old"} -> fn worry -> worry * worry end
      {"*", x} -> fn worry -> worry * String.to_integer(x) end
      {"+", "old"} -> fn worry -> worry + worry end
      {"+", x} -> fn worry -> worry + String.to_integer(x) end
    end
  end
end
