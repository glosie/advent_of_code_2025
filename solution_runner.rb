require 'benchmark'

class SolutionRunner
  def initialize(solution_module, input = nil, sample_input: nil, sample_input_part2: nil, expected_part1: nil, expected_part2: nil)
    @solution_module = solution_module
    @input = input
    @sample_input = sample_input
    @sample_input_part2 = sample_input_part2 || sample_input
    @expected_part1 = expected_part1
    @expected_part2 = expected_part2
  end

  def run
    puts "=== #{@solution_module} Solutions ==="

    # run sample verification if provided
    if @sample_input
      puts "\n--- Sample Input ---"
      verify_sample
      puts ""
    end

    # run actual input
    if @input && @input != ""
      puts "--- Actual Input ---"

      if @solution_module.respond_to?(:part1)
        result1 = nil
        time1 = Benchmark.measure { result1 = @solution_module.part1(@input) }
        puts "Part 1: #{result1} (#{format_time(time1.real)})"
      end

      if @solution_module.respond_to?(:part2)
        result2 = nil
        time2 = Benchmark.measure { result2 = @solution_module.part2(@input) }
        puts "Part 2: #{result2} (#{format_time(time2.real)})"
      end
    end
  end

  private

  def verify_sample
    if @expected_part1 && @solution_module.respond_to?(:part1)
      result = @solution_module.part1(@sample_input)
      status = result == @expected_part1 ? "✓" : "✗"
      puts "Part 1: #{result} (expected: #{@expected_part1}) #{status}"
    end

    if @expected_part2 && @solution_module.respond_to?(:part2)
      result = @solution_module.part2(@sample_input_part2)
      status = result == @expected_part2 ? "✓" : "✗"
      puts "Part 2: #{result} (expected: #{@expected_part2}) #{status}"
    end
  end

  def format_time(seconds)
    if seconds < 0.001
      format("%.2fμs", seconds * 1_000_000)
    elsif seconds < 1
      format("%.2fms", seconds * 1_000)
    else
      format("%.2fs", seconds)
    end
  end
end
