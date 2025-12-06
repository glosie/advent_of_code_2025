module Day6
  class << self
    def part1(input)
      input.each_line.map(&:split).transpose.sum do |problem|
        operator = problem.pop.to_sym
        problem.map(&:to_i).reduce(operator)
      end
    end

    def part2(input)
      columns = input.each_line.map(&:chomp).map(&:chars).transpose.map(&:join)
      columns.chunk { |col| col.strip.empty? }.reject(&:first).sum do |_, cols|
        text = cols.join
        text.scan(/\d+/).map(&:to_i).reduce(text[/[+*\-\/]/].to_sym)
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
