# Advent of Code 2025

My solutions for [Advent of Code 2025](https://adventofcode.com/2025) in Ruby.

## Structure

```
day{N}/
  solution.rb    # Solution module with part1 and part2 methods
  input.txt      # Puzzle input (not committed)
  sample_input.txt
```

## Running Solutions

```bash
ruby day1/solution.rb
```

Each solution verifies against sample input before running the actual puzzle input, with timing for each part.

## Adding a New Day

1. Create `day{N}/solution.rb` with a module or class implementing `part1(input)` and `part2(input)`
2. Add your puzzle input to `day{N}/input.txt`
3. Add sample input to `day{N}/sample_input.txt`
4. Configure expected sample results in the `SolutionRunner` call
