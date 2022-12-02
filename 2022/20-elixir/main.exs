defmodule AOC do
  defp mix_indices(original, indices, size) do
    {delta, i} = original
    current_idx = indices |> Enum.find_index(&(&1 == i))
    {value, indices} = indices |> List.pop_at(current_idx)
    new_idx = Integer.mod(current_idx + delta, size-1)
    indices |> List.insert_at(new_idx, value)
  end

  def mix(input, n) do
    size = length(input)
    indexed_input = input |> Enum.with_index

    Enum.reduce(1..n, Enum.to_list(0..(size-1)), fn _, acc ->
      Enum.reduce(indexed_input, acc, &(mix_indices(&1, &2, size)))
    end)
      |> Enum.map(&Enum.at(input, &1))
  end

  def coordinates(data) do
    size = length(data)
    zero = data |> Enum.find_index(&(&1 == 0))
    [1000, 2000, 3000]
      |> Enum.map(fn val ->
          Enum.at(data, Integer.mod(zero + val, size))
        end)
      |> Enum.sum
  end
end

input = File.read!("input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)

input |> AOC.mix(1) |> AOC.coordinates |> IO.inspect

input |> Enum.map(&(&1 * 811589153)) |> AOC.mix(10) |> AOC.coordinates |> IO.inspect
