defmodule AdventOfCode2022.Day2 do
  use AdventOfCode2022.Solution

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

  def part_one() do
    read_lines!(trim: true)
    |> parse_to_rounds()
    |> sum_round_scores()
  end

  def part_two() do
    read_lines!(trim: true)
    |> parse_to_round_outcomes()
    |> Enum.map(&round_outcome_to_round/1)
    |> sum_round_scores()
  end

  @spec sum_round_scores([round()]) :: integer()
  def sum_round_scores(rounds) do
    Enum.reduce(rounds, 0, fn round, acc -> calculate_round_score(round) + acc end)
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

  @doc ~S"""
      iex> AdventOfCode2022.Day2.parse_to_rounds(["A X", "B Z"])
      [{:rock, :rock}, {:paper, :scissors}]
  """
  def parse_to_rounds(lines) do
    Enum.map(lines, fn line ->
      [opponent, you] = String.split(line)
      {str_to_move(opponent), str_to_move(you)}
    end)
  end

  @doc ~S"""
      iex> AdventOfCode2022.Day2.parse_to_round_outcomes(["A X", "B Z"])
      [{:rock, :lose}, {:paper, :win}]
  """
  def parse_to_round_outcomes(lines) do
    Enum.map(lines, fn line ->
      [opponent, you] = String.split(line)
      {str_to_move(opponent), str_to_outcome(you)}
    end)
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
