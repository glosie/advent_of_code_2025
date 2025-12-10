module Day9
  class << self
    def part1(input)
      points = parse_input(input)
      max_area = 0

      points.combination(2) do |(x1, y1), (x2, y2)|
        next if x1 == x2 || y1 == y2

        area = ((x2 - x1).abs + 1) * ((y2 - y1).abs + 1)
        max_area = [max_area, area].max
      end

      max_area
    end

    def part2(input)
      polygon = parse_input(input)
      vertex_count = polygon.length

      # build edges as line segments
      edges = polygon.each_with_index.map do |(x1, y1), i|
        x2, y2 = polygon[(i + 1) % vertex_count]
        [x1, y1, x2, y2]
      end

      max_area = 0

      polygon.each_with_index do |(x1, y1), i|
        ((i + 1)...vertex_count).each do |j|
          x2, y2 = polygon[j]
          next if x1 == x2 || y1 == y2

          area = ((x2 - x1).abs + 1) * ((y2 - y1).abs + 1)

          # only check intersection if this _could_ be a new max
          next if max_area >= area
          # skip if rectangle extends outside polygon boundary
          next if extends_outside_polygon?(x1, y1, x2, y2, edges)

          max_area = area
        end
      end

      max_area
    end

    private

    def parse_input(input)
      input.each_line.filter_map do |line|
        line.strip.split(',').map(&:to_i) unless line.strip.empty?
      end
    end

    # For rectilinear polygons with rectangle corners at polygon vertices,
    # any edge intersecting the rectangle interior indicates the rectangle
    # would extend outside the polygon. I think.
    def extends_outside_polygon?(x1, y1, x2, y2, edges)
      rect_min_x, rect_max_x = [x1, x2].minmax
      rect_min_y, rect_max_y = [y1, y2].minmax

      edges.any? do |ex1, ey1, ex2, ey2|
        edge_min_x, edge_max_x = [ex1, ex2].minmax
        edge_min_y, edge_max_y = [ey1, ey2].minmax

        edge_max_x > rect_min_x &&
          edge_min_x < rect_max_x &&
          edge_max_y > rect_min_y &&
          edge_min_y < rect_max_y
      end
    end
  end
end

if __FILE__ == $0
  require_relative "../solution_runner"

  sample_input = File.read(File.join(__dir__, "sample_input.txt"))
  input_file = File.join(__dir__, "input.txt")
  input = File.exist?(input_file) && !File.zero?(input_file) ? File.read(input_file) : ""

  SolutionRunner.new(
    Day9,
    input,
    sample_input: sample_input,
    expected_part1: 50,
    expected_part2: 24
  ).run
end
