defmodule ChapterThreeTests do
  use ExUnit.Case
  doctest ChapterThree

  test "It should count the length of each line for a file" do
    assert (
      ChapterThree.line_lenghts!("/home/fabio_fusimoto/code/elixir/learning-elixir/test/fixtures/lines.txt") ==
        [19, 36, 44, 64, 55, 84, 1, 28, 0, 0, 0, 57]
    )
  end

  test "It should return the longest line's length" do
    assert (
      ChapterThree.longest_line_length!("/home/fabio_fusimoto/code/elixir/learning-elixir/test/fixtures/lines.txt") ==
        84
    )
  end

  test "It should return the longest line's content" do
    assert (
      ChapterThree.longest_line!("/home/fabio_fusimoto/code/elixir/learning-elixir/test/fixtures/lines.txt") ==
        "uhausssssefuagu                gfgquiefg             i ul KJABSFK JQBKBJFKABSJK FAKF"
    )
  end
end
