module Day10
  class << self
    def part1(input)
      parse_input(input).sum { |machine| min_presses_for_toggle(machine) }
    end

    def part2(input)
      parse_input(input).sum { |machine| min_presses_for_joltage(machine) }
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

    # Reduces Ax = b to row echelon form, then searches over free variables
    # to find minimum-cost non-negative integer solution.
    #
    # Let x₀, x₁, x₂, x₃, x₄, x₅ be the number of presses for each button.
    #
    # Each button contributes to specific joltage positions:
    # - Button 0: (3) → position 3
    # - Button 1: (1,3) → positions 1, 3
    # - Button 2: (2) → position 2
    # - Button 3: (2,3) → positions 2, 3
    # - Button 4: (0,2) → positions 0, 2
    # - Button 5: (0,1) → positions 0, 1
    #
    # The joltage at each position must equal its target {3,5,4,7}:
    #
    # Position 0:           x₄ + x₅ = 3
    # Position 1:      x₁      + x₅ = 5
    # Position 2:      x₂ + x₃ + x₄ = 4
    # Position 3: x₀ + x₁ + x₃      = 7
    #
    # Constraints:
    #   - All xᵢ ≥ 0 (non-negative integers)
    #   - Minimize Σxᵢ (total button presses)
    #
    #       x₀  x₁  x₂  x₃  x₄  x₅
    # A = [ 0   0   0   0   1   1 ]    b = [ 3 ]
    #     [ 0   1   0   0   0   1 ]        [ 5 ]
    #     [ 0   0   1   1   1   0 ]        [ 4 ]
    #     [ 1   1   0   1   0   0 ]        [ 7 ]
    def min_presses_for_joltage(machine)
      targets, buttons = machine.values_at(:joltage_targets, :buttons)

      # construct augmented matrix [ A | b ]
      matrix = targets.map.with_index do |target, pos|
        buttons.map { |btn| btn.include?(pos) ? 1 : 0 } << target
      end

      row_echelon, pivots = gaussian_elimination(matrix)
      free_vars = (0...buttons.length).to_a - pivots
      button_presses = Array.new(buttons.length, 0)

      dfs(row_echelon, pivots, free_vars, targets.max, button_presses)
    end

    def gaussian_elimination(matrix)
      rows = matrix.map { |row| row.map(&:to_r) }
      n_vars = rows.first.length - 1

      pivots = (0...n_vars).each_with_object([]) do |col, pivots|
        pivot_idx = pivots.length
        swap_idx = (pivot_idx...rows.length).find { |i| rows[i][col] != 0 }
        next unless swap_idx

        rows[pivot_idx], rows[swap_idx] = rows[swap_idx], rows[pivot_idx]
        pivots << col

        # normalize pivot row to have leading 1
        pivot_val = rows[pivot_idx][col]
        rows[pivot_idx] = rows[pivot_idx].map { |v| v / pivot_val }

        # eliminate column from other rows
        rows.each_index do |i|
          next if i == pivot_idx || rows[i][col] == 0
          factor = rows[i][col]
          rows[i] = rows[i].zip(rows[pivot_idx]).map { |v, p| v - factor * p }
        end
      end

      [rows, pivots]
    end

    def dfs(row_echelon, pivots, free_vars, bound, button_presses, depth = 0, cost = 0, best = Float::INFINITY)
      if depth == free_vars.size
        return compute_total_presses(row_echelon, pivots, button_presses)
      end

      col = free_vars[depth]

      (0..bound).each do |val|
        break if cost + val >= best

        button_presses[col] = val
        result = dfs(row_echelon, pivots, free_vars, bound, button_presses, depth + 1, cost + val, best)
        best = [best, result].min
      end

      button_presses[col] = 0
      best
    end

    # Back-substitution
    #
    # Given free variable values, compute pivot variable values.
    #
    # Starting from the last pivot row and working up, each pivot variable is:
    #   x_pivot = RHS - (coefficients × already-solved variables)
    #
    # Returns total presses if solution is valid (non-negative integers),
    # otherwise infinity to signal infeasibility.
    def compute_total_presses(row_echelon, pivots, button_presses)
      solution = button_presses.dup
      n_vars = button_presses.length

      pivots.zip(row_echelon).reverse_each do |col, row|
        val = row.last - (col + 1...n_vars).sum { |c| row[c] * solution[c] }

        return Float::INFINITY unless val.denominator == 1 && val >= 0

        solution[col] = val.to_i
      end

      solution.sum
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
