module Day5
  class << self
    def part1(input)
      ranges, ingredient_ids = parse_input(input)
      merged = merge_ranges(ranges)

      ingredient_ids.count do |id|
        idx = merged.bsearch_index { |r| r.end >= id }
        idx && id >= merged[idx].begin
      end
    end

    def part2(input)
      ranges, _ = parse_input(input)

      merge_ranges(ranges).sum(&:size)
    end

    private

    def parse_input(input)
      ranges_section, ids_section = input.strip.split("\n\n")

      ranges = ranges_section.split("\n").map do |line|
        start, finish = line.split("-").map(&:to_i)
        (start..finish)
      end
      ingredient_ids = ids_section.split("\n").map(&:to_i)

      [ranges, ingredient_ids]
    end

    def merge_ranges(ranges)
      return [] if ranges.empty?

      ranges.sort_by(&:begin).each_with_object([]) do |range, merged|
        if merged.empty? || range.begin > merged.last.end + 1
          merged << range
        else
          merged[-1] = (merged.last.begin..[range.end, merged.last.end].max)
        end
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
    expected_part1: 3,
    expected_part2: 14
  ).run
end
