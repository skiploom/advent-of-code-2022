defmodule Day13Test do
  use ExUnit.Case, async: true
  alias AdventOfCode2022.Day13
  doctest Day13

  describe "sum_correct_indices/1" do
    test "returns sum of all indices (starting at index one) if all pairs are correctly ordered" do
      assert 3 == Day13.sum_correct_indices([{[1], [1, 2]}, {[1, 2], [3]}])
    end

    test "excludes indices from sum if index's pair is not correctly ordered" do
      assert 1 == Day13.sum_correct_indices([{[1], [1, 2]}, {[1, 2], [1]}])
    end
  end

  describe "pair_ordered?/2" do
    test "if all elements in pair are integers, compares each element one-by-one until a decision can be made" do
      assert Day13.pair_ordered?([1, 1, 3, 1, 1], [1, 1, 5, 1, 1])
      assert Day13.pair_ordered?([1, 1, 5, 1, 1], [1, 1, 5, 1, 1])

      refute Day13.pair_ordered?([1, 1, 5, 1, 1], [1, 1, 3, 1, 1])
    end

    test "if pair has two packets of different lengths, returns false if right packet runs out first, true otherwise" do
      refute Day13.pair_ordered?([7, 7, 7, 7], [7, 7, 7])
      refute Day13.pair_ordered?([[[]]], [[]])

      assert Day13.pair_ordered?([7, 7, 7], [7, 7, 7, 7])
      assert Day13.pair_ordered?([[4, 4], 4, 4], [[4, 4], 4, 4, 4])
      assert Day13.pair_ordered?([], [3])
    end

    test "if element N is an integer in one packet and a list in the other, wraps the integer in a list and compares" do
      assert Day13.pair_ordered?([[1], [2, 3, 4]], [[1], 4])

      refute Day13.pair_ordered?([9], [[8, 7, 6]])

      left = [1, [2, [3, [4, [5, 6, 7]]]], 8, 9]
      right = [1, [2, [3, [4, [5, 6, 0]]]], 8, 9]
      refute Day13.pair_ordered?(left, right)
    end
  end

  describe "compare/2" do
    test "returns :lt when left element is less than right" do
      assert_less(Day13.compare(1, 2))
      assert_less(Day13.compare([1, 2], [2, 3]))
      assert_less(Day13.compare([1, 2], [1, 3]))
      assert_less(Day13.compare([1, 2, 3], [2, 3]))
      assert_less(Day13.compare([1, 2], [1, 2, 3]))
      assert_less(Day13.compare(1, [2, 3]))
    end

    test "returns :gt when left element is greater than right" do
      assert_greater(Day13.compare(2, 1))
      assert_greater(Day13.compare([2, 3], [1, 2]))
      assert_greater(Day13.compare([1, 2, 3], [0, 3]))
      assert_greater(Day13.compare([1, 2, 3], [1, 2]))
      assert_greater(Day13.compare([2, 3], 1))

      assert_greater(
        Day13.compare([1, [2, [3, [4, [5, 6, 7]]]], 8, 9], [1, [2, [3, [4, [5, 6, 0]]]], 8, 9])
      )
    end

    test "returns :eq when left element is equal to right" do
      assert :eq == Day13.compare(2, 2)
      assert :eq == Day13.compare([1, 2], [1, 2])
    end
  end

  defp assert_less(result), do: result == :lt
  defp assert_greater(result), do: result == :gt
end
