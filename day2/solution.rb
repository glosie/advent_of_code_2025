module Day2
  module_function

  def part1(input)
    ranges = parse_input(input)
    sum_matching_in_ranges(ranges) { |len| generate_doubled_numbers(len) }
  end

  def part2(input)
    ranges = parse_input(input)
    sum_matching_in_ranges(ranges) { |len| generate_repeated_patterns(len) }
  end

  class << self
    private

    def parse_input(input)
      input.strip.split(',').map do |range|
        range.split('-').map(&:to_i)
      end
    end

    def sum_matching_in_ranges(ranges, &generator)
      max_val = ranges.map(&:last).max
      max_digits = max_val.to_s.length

      # generate all possible invalid ids up to max_digits
      invalid_ids = (2..max_digits).flat_map(&generator).sort

      ranges.sum do |start_id, end_id|
        # binary search for invalid ids within
        left = invalid_ids.bsearch_index { |n| n >= start_id } || invalid_ids.length
        right = invalid_ids.bsearch_index { |n| n > end_id } || invalid_ids.length

        left < right ? invalid_ids[left...right].sum : 0
      end
    end

    # generate ids where the string is exactly doubled (e.g., 1212, 565656)
    def generate_doubled_numbers(total_digits)
      return [] if total_digits.odd?

      n_digit_numbers(total_digits / 2).map { |p| (p.to_s * 2).to_i }
    end

    # generate all ids that are a repeated pattern (e.g., 123123)
    def generate_repeated_patterns(total_digits)
      (1...total_digits)
        .select { |len| total_digits % len == 0 }
        .flat_map do |pattern_len|
          repeat_count = total_digits / pattern_len
          n_digit_numbers(pattern_len).map { |p| (p.to_s * repeat_count).to_i }
        end.uniq
    end

    def n_digit_numbers(n)
      n == 1 ? (1..9) : (10 ** (n - 1)..10 ** n - 1)
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
    expected_part1: 1227775554,
    expected_part2: 4174379265
  ).run
end
