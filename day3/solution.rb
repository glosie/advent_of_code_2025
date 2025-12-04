module Day3
  module_function

  def part1(input)
    input.each_line.sum { |line| largest_n_digit_subsequence(line.to_i, 2) }
  end

  def part2(input)
    input.each_line.sum { |line| largest_n_digit_subsequence(line.to_i, 12) }
  end

  def largest_n_digit_subsequence(number, n)
    digits = number.to_s.chars.map(&:to_i)
    return 0 if digits.length < n

    stack = []
    drops_remaining = digits.length - n

    digits.each do |digit|
      while !stack.empty? && stack.last < digit && drops_remaining > 0
        stack.pop
        drops_remaining -= 1
      end
      stack << digit
    end

    stack.first(n).join.to_i
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
    expected_part1: 357,
    expected_part2: 3121910778619
  ).run
end
