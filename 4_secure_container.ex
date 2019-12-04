defmodule SecureContainer do
    def parse_password_range(filepath) do
        {:ok, file_contents} = File.read(filepath)
        file_contents |> String.split("-") |> Enum.map(&String.to_integer/1)
    end

    def get_possible_valid_combinations(strict, current_password, upper_bound, valid_passwords) do
        if current_password <= upper_bound do
            cond do
                strict and is_valid_strict_password_combination(current_password) ->
                    get_possible_valid_combinations(strict, current_password + 1, upper_bound, valid_passwords ++ [current_password])
                not strict and is_valid_password_combination(current_password) ->
                    get_possible_valid_combinations(strict, current_password + 1, upper_bound, valid_passwords ++ [current_password])
                true ->
                    get_possible_valid_combinations(strict, current_password + 1, upper_bound, valid_passwords)
            end
        else
            valid_passwords
        end
    end

    def is_valid_password_combination(number) do
        number_digits = Integer.digits(number)
        length(number_digits) == 6 and has_two_adjacent_digits(number_digits) and has_only_increasing_digits(Integer.digits(number))
    end

    def is_valid_strict_password_combination(number) do
        number_digits = Integer.digits(number)
        length(number_digits) == 6 and has_strictly_two_adjacent_digits(number_digits) and has_only_increasing_digits(Integer.digits(number))
    end

    def has_two_adjacent_digits([digit, digit | _]), do: true

    def has_two_adjacent_digits([_, some_digit | rest_of_digits]) do
        has_two_adjacent_digits([some_digit | rest_of_digits])
    end

    def has_two_adjacent_digits([_]), do: false

    def has_strictly_two_adjacent_digits([digit, digit, some_digit | rest_of_digits]) do
        if digit == some_digit do
            has_strictly_two_adjacent_digits(skip_digits(rest_of_digits, digit))
        else
            true
        end
    end

    def has_strictly_two_adjacent_digits([digit, digit | _]), do: true

    def has_strictly_two_adjacent_digits([_ | digits]) do
        has_strictly_two_adjacent_digits(digits)
    end

    def has_strictly_two_adjacent_digits([]), do: false

    def has_only_increasing_digits([current_digit, next_digit | rest_of_digits]) do
        cond do
            current_digit > next_digit -> false
            true -> has_only_increasing_digits([next_digit | rest_of_digits])
        end
    end

    def has_only_increasing_digits([_]), do: true

    def skip_digits([], _), do: []

    def skip_digits([current_digit | rest_of_digits], digit_to_skip) do
        if current_digit == digit_to_skip do
            skip_digits(rest_of_digits, digit_to_skip)
        else
            [current_digit | rest_of_digits]
        end
    end
end

defmodule Day4 do
    def part1([lower_bound, upper_bound]) do
        IO.inspect length(SecureContainer.get_possible_valid_combinations(false, lower_bound, upper_bound, []))
        [lower_bound, upper_bound]   
    end
    def part2([lower_bound, upper_bound]) do
        IO.inspect length(SecureContainer.get_possible_valid_combinations(true, lower_bound, upper_bound, []))
    end
end

SecureContainer.parse_password_range("inputs/4_input.txt")
    |> Day4.part1
    |> Day4.part2
