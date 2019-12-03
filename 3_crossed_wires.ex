defmodule Wire do
    def get_paths(program_path) do
        {:ok, file_contents} = File.read(program_path)
        lines = file_contents |> String.split("\n") |> Enum.map(&String.trim/1)
        lines = Enum.slice(lines, 0, length(lines) - 1)
        Enum.map(lines, fn line -> String.split(line, ",") end)
    end

    def parse_instruction(instruction) do
        move_type = String.at(instruction, 0)
        number_of_moves = String.slice(instruction, 1..-1) |> String.to_integer
        {move_type, number_of_moves}
    end

    def get_closest_intersection(wire_a, wire_b) do
        {wire_a_map, _} = generate_map(MapSet.new(), {0, 0}, wire_a, Map.new(), 1)
        {wire_b_map, _} = generate_map(MapSet.new(), {0, 0}, wire_b, Map.new(), 1)

        distances = MapSet.intersection(wire_a_map, wire_b_map) |> Enum.map(&manhattan_distance/1)
        
        distances_without_starting_point = Enum.filter(distances, fn x -> x != 0 end)
        
        Enum.min(distances_without_starting_point)
    end

    def get_optimal_intersection(wire_a, wire_b) do
        {wire_a_map, wire_a_step_map} = generate_map(MapSet.new(), {0, 0}, wire_a, Map.new(), 1)
        {wire_b_map, wire_b_step_map} = generate_map(MapSet.new(), {0, 0}, wire_b, Map.new(), 1)

        intersections = MapSet.intersection(wire_a_map, wire_b_map)
        intersections_with_steps = Enum.map(intersections, fn {x, y} -> {x, y, Map.get(wire_a_step_map, {x,y}) + Map.get(wire_b_step_map, {x,y})} end)
        
        {_, _, optimal_num_steps} = Enum.min_by(intersections_with_steps, fn {_, _, num_steps} -> num_steps end)
        
        optimal_num_steps
    end

    def manhattan_distance({x, y}) do
        abs(x) + abs(y)
    end

    def generate_map(map, {x, y}, [instruction | rest_of_wire], steps_map, step_count) do
        {move, times} = parse_instruction(instruction)
        {visited_map, new_x, new_y, new_steps_map} = visit_map(map, {x, y}, move, times, steps_map, step_count)
        generate_map(visited_map, {new_x, new_y}, rest_of_wire, new_steps_map, step_count + times)
    end

    def generate_map(map, _, [], steps_map, _) do
        {map, steps_map}
    end

    def visit_map(map, {x, y}, move, times, steps_map, step_count) do
        cond do
            times > 0 ->
                {new_x, new_y} = generate_new_coordinates({x, y}, move)
                new_map_state = MapSet.put(map, {new_x, new_y})

                if not Map.has_key?(steps_map, {new_x, new_y}) do
                    visit_map(new_map_state, {new_x, new_y}, move, times - 1, Map.put(steps_map, {new_x, new_y}, step_count), step_count + 1)
                else
                    visit_map(new_map_state, {new_x, new_y}, move, times - 1, steps_map, step_count + 1)
                end
            true ->
                {map, x, y, steps_map}
        end
    end

    def generate_new_coordinates({x, y}, move) do
        case move do
            "R" -> {x + 1, y}
            "U" -> {x, y + 1}
            "L" -> {x - 1, y}
            "D" -> {x, y - 1}
        end
    end
end

defmodule Day3 do
    def part1([wire_a, wire_b]) do
        IO.puts Wire.get_closest_intersection(wire_a, wire_b)
        [wire_a, wire_b]
    end

    def part2([wire_a, wire_b]) do
        IO.puts Wire.get_optimal_intersection(wire_a, wire_b)
    end
end

Wire.get_paths("inputs/3_input.txt")
    |> Day3.part1
    |> Day3.part2
