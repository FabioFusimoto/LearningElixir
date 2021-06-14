defmodule ChapterThreeTests do
  use ExUnit.Case
  doctest ChapterThree

  test "It should count the length of each line for a file" do
    assert (
      ChapterThree.line_lenghts!("/home/fabiopires/code/LearningElixir/test/fixtures/line_lengths.txt") ==
        [19, 36, 44, 65, 56, 86, 1, 28, 0, 0, 0, 57]
    )
  end
end
