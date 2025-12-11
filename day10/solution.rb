module Day10
  class << self
    def part1(input)
      parse_input(input).sum { |machine| min_presses_for_toggle(machine) }
    end

    private

    def parse_input(input)
      input.strip.lines.map do |line|
        target_state = line[/\[([.#]+)\]/, 1].chars.map { |c| c == '#' }
        buttons = line.scan(/\(([^)]+)\)/).map { |m| m[0].split(',').map(&:to_i) }
        joltage_targets = line[/\{([^}]+)\}/, 1].split(',').map(&:to_i)

        { target_state:, buttons:, joltage_targets: }
      end
    end

    def min_presses_for_toggle(machine)
      target, buttons = machine.values_at(:target_state, :buttons)

      (0...2**buttons.length).filter_map do |mask|
        mask.digits(2).count(1) if toggles_to_target?(buttons, mask, target)
      end.min
    end

    def toggles_to_target?(buttons, mask, target)
      state = Array.new(target.length, false)
      buttons.each_with_index do |positions, i|
        positions.each { |pos| state[pos] ^= true } if mask[i] == 1
      end
      state == target
    end
  end
end

if __FILE__ == $0
  require_relative "../solution_runner"

  sample_input = File.read(File.join(__dir__, "sample_input.txt"))
  input_file = File.join(__dir__, "input.txt")
  input = File.exist?(input_file) && !File.zero?(input_file) ? File.read(input_file) : ""

  SolutionRunner.new(
    Day10,
    input,
    sample_input:,
    expected_part1: 7,
    expected_part2: 33
  ).run
end
