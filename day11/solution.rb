module Day11
  class << self
    def part1(input)
      graph = parse_input(input)
      count_paths(graph, 'you', 'out')
    end

    def part2(input)
      graph = parse_input(input)
      count_paths(graph, 'svr', 'out', waypoints: ['dac', 'fft'])
    end

    private

    def parse_input(input)
      input.each_line.to_h do |line|
        node, neighbors = line.split(": ")
        [node, neighbors.split]
      end
    end

    def count_paths(graph, start, target, waypoints: [])
      # bitmask to track which waypoints were visited on each path.
      # for waypoints ['dac', 'fft']: dac sets bit 0 (0b01), fft sets
      # bit 1 (0b10). target_mask = 0b11 means both visited.
      target_mask = (1 << waypoints.size) - 1

      path_counts = Hash.new { |h, k| h[k] = Hash.new(0) }
      path_counts[start][waypoint_mask(start, waypoints)] = 1

      topological_sort(graph).each do |node|
        graph.fetch(node, []).each do |neighbor|
          path_counts[node].each do |mask, count|
            new_mask = mask | waypoint_mask(neighbor, waypoints)
            path_counts[neighbor][new_mask] += count
          end
        end
      end

      path_counts[target][target_mask]
    end

    def waypoint_mask(node, waypoints)
      idx = waypoints.index(node)
      idx ? (1 << idx) : 0
    end

    def topological_sort(graph)
      all_nodes = graph.keys.to_set | graph.values.flatten.to_set
      in_degree = Hash.new(0)
      graph.each_value { |neighbors| neighbors.each { |n| in_degree[n] += 1 } }

      queue = all_nodes.reject { |n| in_degree[n] > 0 }
      result = []

      while (node = queue.shift)
        result << node
        graph.fetch(node, []).each do |neighbor|
          in_degree[neighbor] -= 1
          queue << neighbor if in_degree[neighbor] == 0
        end
      end

      raise "Graph is not a DAG" if result.size != all_nodes.size

      result
    end
  end
end

if __FILE__ == $0
  require_relative "../solution_runner"

  sample_input_part1 = File.read(File.join(__dir__, "sample_input.txt"))
  sample_input_part2 = File.read(File.join(__dir__, "part_2_sample_input.txt"))
  input_file = File.join(__dir__, "input.txt")
  input = File.exist?(input_file) && !File.zero?(input_file) ? File.read(input_file) : ""

  SolutionRunner.new(
    Day11,
    input,
    sample_input: sample_input_part1,
    sample_input_part2: sample_input_part2,
    expected_part1: 5,
    expected_part2: 2
  ).run
end
