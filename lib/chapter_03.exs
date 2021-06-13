defmodule ChapterThree do
  def line_lenghts! (file) do
    File.Stream!(path)
    |> Stream.map(&(String.length(&1)))
    |> Enum.to_list()
  end

  def longest_line_lenght! (file) do
    file
  end
end
