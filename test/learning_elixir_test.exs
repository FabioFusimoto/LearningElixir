defmodule RnaToDnaTest do
  use ExUnit.Case
  doctest RnaToDna

  test "It should convert an DNA string to a RNA string" do
    assert RnaToDna.convert_dna_to_rna('GCTA') == 'CGAU'
  end
end

defmodule WordCountTest do
  use ExUnit.Case
  doctest WordCount

  test "It should count the frequencies of each word in the phrase" do
    assert (
      WordCount.count("olly olly in come free") ==
        %{"olly" => 2, "in" => 1, "come" => 1, "free" => 1}
    )
  end
end
