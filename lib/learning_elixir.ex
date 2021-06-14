defmodule LearningElixir do
  @moduledoc "LearningElixir"
  def hello_world() do
    IO.puts("Hello World!")
  end
end

defmodule RnaToDna do
  defp convert_nucleotide (nuc) do
    case nuc do
      ?G -> ?C
      ?C -> ?G
      ?T -> ?A
      ?A -> ?U
    end
  end

  def convert_dna_to_rna (dna) do
    Enum.map(dna, &convert_nucleotide/1)
  end
end

defmodule WordCount do
  def count(phrase) do
    phrase
    |> String.split()
    |> Enum.frequencies()
  end
end

defmodule BeerSong do
  defp count_dependent_strings(beers) do
    cond do
      beers > 1 ->
        {"#{beers} bottles", "one"}
      beers == 1 ->
        {"1 bottle", "it"}
      true ->
        {"no more bottles", ""}
    end
  end

  def lyrics(repetitions) do
    Enum.each(
      repetitions..0,
      fn beers ->
        if beers !== 0 do
          {n_bottles_or_bottle, one_or_it} = count_dependent_strings(beers)
          {n_minus_1_bottles_or_bottle, _} = count_dependent_strings(beers - 1)
          IO.puts("#{n_bottles_or_bottle} of beer on the wall, #{n_bottles_or_bottle} of beer.")
          IO.puts("Take #{one_or_it} down and pass it around, #{n_minus_1_bottles_or_bottle} of beer on the wall.\n")
        else
          IO.puts("No more bottles of beer on the wall, no more bottles of beer.")
          IO.puts("Go to the store and buy some more, #{repetitions} bottles of beer on the wall.")
        end
      end
    )
  end
end
