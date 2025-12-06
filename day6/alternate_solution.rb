module Day6
  class << self
    def part1(input)
      extract_problems(input, :rows).sum { solve(it) }
    end

    def part2(input)
      extract_problems(input, :cols).sum { solve(it) }
    end

    private

    def solve(problem)
      operator = problem.pop.to_sym
      problem.map(&:to_i).reduce(operator)
    end

    def extract_problems(input, direction)
      grid = input.each_line.map(&:chomp).map(&:chars)

      grid.transpose
          .chunk { |col| col.all?(" ") }
          .reject(&:first)
          .map { |_, cols| extract_tokens(cols, direction) }
    end

    def extract_tokens(cols, direction)
      case direction
      when :rows
        cols.transpose.map { it.join.strip }.reject(&:empty?)
      when :cols
        text = cols.flatten.join
        cols.map { |col| col.join.tr("^0-9", "") }.reject(&:empty?) << text[/[+*\-\/]/]
      end
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
    expected_part1: 4277556,
    expected_part2: 3263827
  ).run
end
