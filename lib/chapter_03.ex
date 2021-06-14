defmodule ChapterThree do
  def line_lenghts!(file) do
    File.stream!(file)
    |> Stream.map(&String.length(&1))
    |> Enum.to_list()
  end

  def longest_line_length!(file) do
    file
  end
end
