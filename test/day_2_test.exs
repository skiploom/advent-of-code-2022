defmodule Day2Test do
  use ExUnit.Case

  alias AdventOfCode2022.Day2

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

  describe "parse_input_line/2" do
    test "parses string into a round(), if answering question part 1" do
      assert Day2.parse_input_line("C Z", :part_one) == {:scissors, :scissors}
      assert Day2.parse_input_line("A Y", :part_one) == {:rock, :paper}
    end

    test "parses string into a round_outcome(), if answering question part 2" do
      assert Day2.parse_input_line("C Z", :part_two) == {:scissors, :win}
      assert Day2.parse_input_line("A Y", :part_two) == {:rock, :draw}
    end
  end
end
