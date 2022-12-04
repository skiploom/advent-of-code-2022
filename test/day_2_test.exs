defmodule Day2Test do
  use ExUnit.Case

  alias AdventOfCode2022.Day2
  doctest Day2

  describe "calculate_round_score/1" do
    test "totals score as expected" do
      assert Day2.calculate_round_score({:rock, :rock}) == 1 + 3
      assert Day2.calculate_round_score({:rock, :scissors}) == 3 + 0
      assert Day2.calculate_round_score({:rock, :paper}) == 2 + 6
    end
  end

  describe "round_outcome_to_round/1" do
    test "correctly figures out your move (and therefore the round()), based on the given outcome" do
      expected_round = {:rock, :paper}
      assert Day2.round_outcome_to_round({:rock, :win}) == expected_round
    end
  end

  describe "parse_to_rounds/1" do
    test "parses strings into round()s" do
      assert Day2.parse_to_rounds(["C Z", "A Y"]) == [{:scissors, :scissors}, {:rock, :paper}]
    end
  end

  describe "parse_to_round_outcomes/1" do
    test "parses strings into round_outcome()s" do
      assert Day2.parse_to_round_outcomes(["C Z", "A Y"]) == [{:scissors, :win}, {:rock, :draw}]
    end
  end
end
