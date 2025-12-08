module Day8
  class << self
    def part1(input)
      coordinates = parse_coordinates(input)

      # adjust limit for sample input
      num_connections = coordinates.size <= 20 ? 10 : 1000

      # build heap of shortest distances between junction boxes
      heap = BoundedMaxHeap.new(num_connections)
      indexed_coordinates = coordinates.each_with_index.to_a
      indexed_coordinates.combination(2) do |(coord1, i), (coord2, j)|
        distance = distance_squared(coord1, coord2)
        heap.push([distance, i, j])
      end

      # connect circuits
      union_find = UnionFind.new(coordinates.size)
      heap.each { |_, i, j| union_find.union(i, j) }

      union_find.component_sizes.max(3).reduce(:*)
    end

    def part2(input)
      coordinates = parse_coordinates(input)

      indexed_coordinates = coordinates.each_with_index.to_a
      connections = indexed_coordinates.combination(2).map do |(coord1, i), (coord2, j)|
        [distance_squared(coord1, coord2), i, j]
      end

      connections.sort_by!(&:first)
      union_find = UnionFind.new(coordinates.size)

      # make all connections
      connections.each do |_, i, j|
        next unless union_find.union(i, j)
        return coordinates[i][0] * coordinates[j][0] if union_find.connected?
      end

      raise "No spanning tree found"
    end

    private

    def parse_coordinates(input)
      input.each_line.map { |line| line.split(',').map(&:to_i) }
    end

    def distance_squared(coord1, coord2)
      x1, y1, z1 = coord1
      x2, y2, z2 = coord2
      (x2 - x1)**2 + (y2 - y1)**2 + (z2 - z1)**2
    end
  end

  # Bounded max-heap for tracking the N smallest elements
  class BoundedMaxHeap
    include Enumerable

    def initialize(capacity)
      @capacity = capacity
      @data = []
    end

    def push(item)
      if @data.size < @capacity
        @data << item
        bubble_up(@data.size - 1)
      elsif item.first < @data[0].first
        @data[0] = item
        bubble_down(0)
      end
    end

    def each
      return enum_for(:each) unless block_given?

      @data.each { |item| yield item }
    end

    private

    def bubble_up(idx)
      return if idx == 0
      parent = (idx - 1) / 2
      return if @data[parent].first >= @data[idx].first

      @data[parent], @data[idx] = @data[idx], @data[parent]
      bubble_up(parent)
    end

    def bubble_down(idx)
      children = [2 * idx + 1, 2 * idx + 2].select { |i| i < @data.size }
      return if children.empty?

      largest = children.max_by { |i| @data[i].first }
      return if @data[idx].first >= @data[largest].first

      @data[idx], @data[largest] = @data[largest], @data[idx]
      bubble_down(largest)
    end
  end

  # Union-Find (Disjoint-set) data structure for tracking connected components
  class UnionFind
    def initialize(size)
      @parent = (0...size).to_a
      @rank = Array.new(size, 0)
      @size = Array.new(size, 1)
      @components = size
    end

    def find(node)
      if @parent[node] != node
        @parent[node] = find(@parent[node])  # path compression
      end
      @parent[node]
    end

    def union(a, b)
      root_a = find(a)
      root_b = find(b)

      return false if root_a == root_b

      # union-by-rank: attach smaller tree under larger
      root_a, root_b = root_b, root_a if @rank[root_a] < @rank[root_b]

      @parent[root_b] = root_a
      @size[root_a] += @size[root_b]
      @rank[root_a] += 1 if @rank[root_a] == @rank[root_b]
      @components -= 1
      true
    end

    def connected?
      @components == 1
    end

    # returns an array of component sizes (one entry per component).
    def component_sizes
      @parent.each_index.filter_map { |i| @size[i] if @parent[i] == i }
    end
  end
end

if __FILE__ == $0
  require_relative "../solution_runner"

  sample_input = File.read(File.join(__dir__, "sample_input.txt"))
  input_file = File.join(__dir__, "input.txt")
  input = File.exist?(input_file) && !File.zero?(input_file) ? File.read(input_file) : ""

  SolutionRunner.new(
    Object.const_get(File.basename(__dir__).capitalize),
    input.empty? ? nil : input,
    sample_input: sample_input,
    expected_part1: 40,
    expected_part2: 25272
  ).run
end
