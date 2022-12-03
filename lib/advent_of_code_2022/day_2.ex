defmodule AdventOfCode2022.Day2 do
  @score_rock 1
  @score_paper 2
  @score_scissors 3
  @score_lose 0
  @score_draw 3
  @score_win 6

  @type move :: :rock | :paper | :scissors
  @type round :: {opponent_move :: move(), your_move :: move()}
  @type outcome :: :win | :lose | :draw
  @type round_outcome :: {opponent_move :: move(), your_outcome :: outcome()}

  @type question_part :: :part_one | :part_two

  def answer() do
    part1 =
      read!(:part_one)
      |> Enum.map(&calculate_round_score/1)
      |> Enum.sum()

    part2 =
      read!(:part_two)
      |> Enum.map(&round_outcome_to_round/1)
      |> Enum.map(&calculate_round_score/1)
      |> Enum.sum()

    {part1, part2}
  end

  @spec calculate_round_score(round()) :: integer()
  def calculate_round_score({_opponent, you} = round) do
    shape_score(you) + outcome_score(round)
  end

  @spec shape_score(move()) :: integer()
  def shape_score(move) do
    case move do
      :rock -> @score_rock
      :paper -> @score_paper
      :scissors -> @score_scissors
    end
  end

  @spec outcome_score(round) :: integer()
  def outcome_score(round) do
    case round do
      {x, x} -> @score_draw
      {:paper, :rock} -> @score_lose
      {:scissors, :paper} -> @score_lose
      {:rock, :scissors} -> @score_lose
      {:scissors, :rock} -> @score_win
      {:rock, :paper} -> @score_win
      {:paper, :scissors} -> @score_win
    end
  end

  @spec round_outcome_to_round(round_outcome()) :: round()
  def round_outcome_to_round({opponent_move, _} = round_outcome) do
    your_move =
      case round_outcome do
        {opp, :draw} -> opp
        {:rock, :win} -> :paper
        {:rock, :lose} -> :scissors
        {:paper, :win} -> :scissors
        {:paper, :lose} -> :rock
        {:scissors, :win} -> :rock
        {:scissors, :lose} -> :paper
      end

    {opponent_move, your_move}
  end

  def read!(question_part) do
    File.read!("inputs/day_2.txt")
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_input_line(&1, question_part))
  end

  @spec parse_input_line(String.t(), question_part()) :: round() | round_outcome()
  def parse_input_line(input_line, part) do
    your_parse_fn =
      case part do
        :part_one -> &str_to_move/1
        :part_two -> &str_to_outcome/1
      end

    [opponent, you] = String.split(input_line)
    {str_to_move(opponent), your_parse_fn.(you)}
  end

  @spec str_to_move(String.t()) :: move()
  def str_to_move(str) do
    case str do
      s when s in ["A", "X"] -> :rock
      s when s in ["B", "Y"] -> :paper
      s when s in ["C", "Z"] -> :scissors
    end
  end

  @spec str_to_outcome(String.t()) :: outcome()
  def str_to_outcome(str) do
    case str do
      "X" -> :lose
      "Y" -> :draw
      "Z" -> :win
    end
  end
end
