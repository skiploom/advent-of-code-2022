defmodule Day8Test do
  use ExUnit.Case, async: true
  alias AdventOfCode2022.Day8
  doctest Day8

  describe "tree_visible?/2" do
    test "true when other trees are shorter" do
      assert Day8.tree_visible?(%{height: 2}, [1, 0, 1])
    end

    test "false when there's a taller tree" do
      refute Day8.tree_visible?(%{height: 2}, [1, 3, 1])
    end

    test "false when there's a tree that's the same height" do
      refute Day8.tree_visible?(%{height: 2}, [1, 2, 1])
    end

    test "can detect blocking trees even if they're right next your tree, or all the way at the edge" do
      refute Day8.tree_visible?(%{height: 2}, [1, 0, 2])
      refute Day8.tree_visible?(%{height: 2}, [2, 0, 1])
    end
  end

  describe "calculate_viewing_distance/2" do
    test "returns 0 if you're at the edge" do
      assert Day8.calculate_viewing_distance(%{height: 2}, []) == 0
    end

    test "returns the number of trees you can see until you hit a same-height or taller tree" do
      assert Day8.calculate_viewing_distance(%{height: 2}, [1, 0, 1]) == 3
      assert Day8.calculate_viewing_distance(%{height: 2}, [1, 2, 1]) == 2
      assert Day8.calculate_viewing_distance(%{height: 2}, [2, 0, 1]) == 1
      assert Day8.calculate_viewing_distance(%{height: 2}, [1, 0, 2]) == 3
    end
  end
end
