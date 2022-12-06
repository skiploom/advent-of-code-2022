defmodule AdventOfCode2022.Day6 do
  use AdventOfCode2022.Solution

  @start_of_packet_marker_length 4
  @start_of_message_marker_length 14

  @type buffer() :: String.t()
  @type marker() :: String.t()

  def part_one(), do: find_marker_location(get_buffer(), @start_of_packet_marker_length)
  def part_two(), do: find_marker_location(get_buffer(), @start_of_message_marker_length)

  @spec find_marker_location(buffer(), expected_marker_length :: integer()) :: integer()
  def find_marker_location(buffer, marker_length) do
    {initial_queue, remaining_buffer} = enqueue_from_buffer([], buffer, marker_length)
    find_marker_location(remaining_buffer, initial_queue, marker_length)
  end

  @typep queue() :: [String.t()]

  @spec find_marker_location(buffer(), queue(), acc :: integer()) :: integer()
  defp find_marker_location("", queue, acc) do
    if all_unique?(queue) do
      acc
    else
      raise("No marker found in input buffer.")
    end
  end

  defp find_marker_location(buffer, queue, acc) do
    if all_unique?(queue) do
      acc
    else
      {new_queue, remaining_buffer} = enqueue_from_buffer(queue, buffer, 1)
      find_marker_location(remaining_buffer, new_queue, acc + 1)
    end
  end

  @spec enqueue_from_buffer(queue(), buffer(), num_elements_to_enqueue :: integer()) ::
          {queue(), buffer()}
  defp enqueue_from_buffer(queue, buffer, num) do
    {chars_to_enqueue_str, new_buffer} = String.split_at(buffer, num)
    new_queue = Enum.drop(queue, num) ++ String.split(chars_to_enqueue_str, "", trim: true)
    {new_queue, new_buffer}
  end

  defp all_unique?(queue), do: Enum.count(Enum.uniq(queue)) == Enum.count(queue)

  @spec get_buffer() :: String.t()
  def get_buffer(), do: hd(read_lines!(trim: true))
end
