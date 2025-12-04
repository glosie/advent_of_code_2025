require 'set'

module Day4
  class << self
    def part1(input)
      grid = parse_grid(input)
      graph = build_graph_from_grid(grid)
      graph.nodes.count { |node| node.degree < 4 }
    end

    def part2(input)
      grid = parse_grid(input)
      graph = build_graph_from_grid(grid)

      total_removed = 0

      loop do
        to_remove = graph.nodes.select { |node| node.degree < 4 }
        break if to_remove.empty?

        graph.remove_nodes(to_remove)
        total_removed += to_remove.size
      end

      total_removed
    end

    private

    def parse_grid(input)
      input.strip.lines.map { |line| line.strip.chars }
    end

    def build_graph_from_grid(grid)
      graph = Graph.new

      grid.each_with_index do |row, r|
        row.each_with_index do |cell, c|
          next unless cell == '@'

          current_node = Node.new(r, c)
          graph.add_node(current_node)

          # since we're moving through the grid left-to-right, top-to-bottom,
          # we can avoid creating duplicate edges by only checking previously
          # processed neighbors (left, up-left, up, up-right)
          [[-1, 0], [-1, -1], [0, -1], [-1, 1]].each do |dr, dc|
            neighbor_node = graph.node_at(r + dr, c + dc)
            graph.add_edge(current_node, neighbor_node) if neighbor_node
          end
        end
      end

      graph
    end
  end

  class Node
    attr_reader :row, :col, :neighbors

    def initialize(row, col)
      @row, @col = row, col
      @neighbors = Set.new
    end

    def degree
      @neighbors.size
    end

    def ==(other)
      other.is_a?(Node) && @row == other.row && @col == other.col
    end
    alias eql? ==

    def hash
      [@row, @col].hash
    end

    def to_s
      "[#{@row},#{@col}]"
    end

    def inspect
      "Node(#{@row}, #{@col})"
    end
  end

  class Graph
    def initialize
      @nodes_by_position = {}
    end

    def nodes
      @nodes_by_position.values
    end

    def add_node(node)
      @nodes_by_position[[node.row, node.col]] = node
    end

    def node_at(row, col)
      @nodes_by_position[[row, col]]
    end

    def add_edge(node1, node2)
      node1.neighbors << node2
      node2.neighbors << node1
    end

    def remove_node(node)
      node.neighbors.each { |neighbor| neighbor.neighbors.delete(node) }
      @nodes_by_position.delete([node.row, node.col])
    end

    def remove_nodes(nodes)
      nodes.each { |node| remove_node(node) }
    end
  end
end

if __FILE__ == $0
  require_relative "../solution_runner"

  sample_input = File.read(File.join(__dir__, "sample_input.txt"))
  input = File.read(File.join(__dir__, "input.txt"))

  SolutionRunner.new(
    Day4,
    input,
    sample_input:,
    expected_part1: 13,
    expected_part2: 43
  ).run
end
