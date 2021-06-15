defmodule ChapterThree do
  def line_lenghts!(file) do
    File.stream!(file)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.length(&1))
    |> Enum.to_list()
  end

  defp highest(a, b) do
    if a > b do
      a
    else
      b
    end
  end

  def longest_line_length!(file) do
    File.stream!(file)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.length(&1))
    |> Enum.reduce(0, &highest(&1, &2))
  end

  defp keep_longest_line(new_line, previous_line_tuple = {_, previous_line_length}) do
    new_line_length = String.length(new_line)
    if new_line_length > previous_line_length do
      {new_line, new_line_length}
    else
      previous_line_tuple
    end
  end

  def longest_line!(file) do
    File.stream!(file)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.reduce({"", 1}, &keep_longest_line(&1, &2))
    |> elem(0)
  end
end
