defmodule IntcodeProcessor do
    
    def execute_intcode(data, position) do
        case Enum.at(data, position) do
            1 ->
                execute_operation(&+/2, data, position)
            2 ->
                execute_operation(&*/2, data, position)
            99 ->
                Enum.at(data, 0)
        end
    end

    def execute_operation(operation, data, position) do
        a_location = Enum.at(data, position + 1)
        b_location = Enum.at(data, position + 2)

        a_value = Enum.at(data, a_location)
        b_value = Enum.at(data, b_location)

        destination_location = Enum.at(data, position + 3)
        
        data = List.replace_at(data, destination_location, operation.(a_value, b_value))

        execute_intcode(data, position + 4)
    end

    def parse_intcode(program_input) do
        program_input
            |> String.split(",")
            |> Enum.map(&String.trim/1)
            |> Enum.map(&String.to_integer/1)
    end

    def output_matches(program, output) do
        execute_intcode(program, 0) == output
    end

    def find_pair(program, pairs_to_check) do
        pair = hd(pairs_to_check)
        program = List.replace_at(program, 1, Enum.at(pair, 0))
        program = List.replace_at(program, 2, Enum.at(pair, 1))

        case output_matches(program, 19690720) do
            true ->
                pair
            false ->
                find_pair(program, tl(pairs_to_check))
        end
    end
end


defmodule Day2 do
    def part_one(program) do
        program = List.replace_at(program, 1, 12)
        program = List.replace_at(program, 2, 2)
        IO.puts IntcodeProcessor.execute_intcode(program, 0)
        program
    end

    def part_two(program) do
        noun_verb_combinations = for x <- 0..99, y <- 0..99, x != y, do: [x, y]
        [noun, verb] = IntcodeProcessor.find_pair(program, noun_verb_combinations)
        IO.puts 100 * noun + verb
        program
    end
end


{:ok, file_contents} = File.read("inputs/2_input.txt")
program = IntcodeProcessor.parse_intcode(file_contents)

program
    |> Day2.part_one
    |> Day2.part_two