module Day7
  class << self
    def part1(input)
      grid = parse_grid(input)
      _, start_col = find_start_position(grid)

      active_beams = [start_col]
      split_count = 0

      grid.drop(1).each do |row|
        active_beams, new_splits = process_row(row, active_beams)
        split_count += new_splits
        break if active_beams.empty?
      end

      split_count
    end

    def part2(input)
      grid = parse_grid(input)
      start_row, start_col = find_start_position(grid)
      max_col = grid.first.size - 1

      paths = { start_col => 1 }

      (start_row...grid.size - 1).each do |row|
        paths = paths.each_with_object(Hash.new(0)) do |(col, count), next_paths|
          get_next_positions(col, grid[row][col], max_col).each do |new_col|
            next_paths[new_col] += count
          end
        end
      end

      paths.values.sum
    end

    private

    def parse_grid(input)
      input.each_line.map(&:chars)
    end

    def find_start_position(grid)
      grid.each_with_index do |row, r|
        col = row.index('S')
        return [r, col] if col
      end
    end

    def get_next_positions(current_col, cell_value, max_col)
      if cell_value == '^'
        [current_col - 1, current_col + 1].select { |c| c.between?(0, max_col) }
      else
        [current_col]
      end
    end

    def process_row(row, active_beams)
      splits = 0

      new_beams = active_beams.flat_map do |col|
        positions = get_next_positions(col, row[col], row.size - 1)
        splits += 1 if positions.size > 1
        positions
      end

      [new_beams.uniq, splits]
    end

  end
end

if __FILE__ == $0
  require_relative "../solution_runner"

  sample_input = File.read(File.join(__dir__, "sample_input.txt"))
  input = File.read(File.join(__dir__, "input.txt"))

  SolutionRunner.new(
    Object.const_get(File.basename(__dir__).capitalize),
    input,
    sample_input:,
    expected_part1: 21,
    expected_part2: 40
  ).run
end
