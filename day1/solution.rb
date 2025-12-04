module Day1
  DIAL_SIZE = 100
  STARTING_POSITION = 50

  module_function

  def part1(input)
    dial = Dial.new

    parse_input(input).count do |direction, distance|
      dial.rotate(direction, distance).landed_on_zero?
    end
  end

  def part2(input)
    dial = Dial.new

    parse_input(input).sum do |direction, distance|
      zeros = dial.zeros_crossed_by(direction, distance)
      dial.rotate(direction, distance)
      zeros
    end
  end

  def parse_input(input)
    input.each_line.map { |line| [line[0], line[1..].to_i] }
  end

  class Dial
    attr_reader :position, :size

    def initialize(position = STARTING_POSITION, size = DIAL_SIZE)
      @position = position
      @size = size
      @zero_count = 0
    end

    def rotate(direction, distance)
      @position += direction == 'L' ? -distance : distance
      self
    end

    def current_position
      @position % @size
    end

    def landed_on_zero?
      current_position.zero?
    end

    def zeros_crossed_by(direction, distance)
      start_mod = current_position

      distance_to_first_zero = case
                               when start_mod.zero? then @size
                               when direction == 'R' then @size - start_mod
                               else start_mod
                               end

      if distance < distance_to_first_zero
        0
      else
        1 + (distance - distance_to_first_zero) / @size
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
    expected_part2: 6
  ).run
end
