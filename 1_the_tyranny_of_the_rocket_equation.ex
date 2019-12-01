defmodule Calculator do
    def calculate_needed_fuel(mass) do
        div(mass, 3) - 2
    end
end

{:ok, file_contents} = File.read("inputs/1_input.txt")

masses = file_contents
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)

total_needed_mass = List.foldl(masses, 0, fn x, acc -> Calculator.calculate_needed_fuel(x) + acc end)

IO.puts total_needed_mass

