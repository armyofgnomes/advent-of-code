#!/usr/bin/env ruby
require 'set'
require_relative '../helpers/matrix'

# Part 1
file = File.read('2024/day-12/day-12-inputs.txt')

matrix = convert_to_matrix(file)

# Example garden
# AAAA
# BBCD
# BBCC
# EEEC

def dfs(matrix, x, y, visited, current_letter)
  # Base cases for invalid moves or already visited cells
  return [] if x < 0 || x >= matrix.length ||
               y < 0 || y >= matrix[0].length ||
               visited.include?([x, y]) ||
               matrix[x][y] != current_letter

  # Mark current position as visited
  visited.add([x, y])

  # Store current position in region
  region = [[x, y]]

  # Directions: right, left, down, up
  directions = [[0, 1], [0, -1], [1, 0], [-1, 0]]

  # Recursively explore all adjacent cells
  directions.each do |dx, dy|
    new_x, new_y = x + dx, y + dy
    region.concat(dfs(matrix, new_x, new_y, visited, current_letter))
  end

  region
end

# Use DFS to find all connected regions
def find_regions(matrix)
  visited = Set.new
  regions = []

  matrix.each_with_index do |row, x|
    row.each_with_index do |cell, y|
      unless visited.include?([x, y])
        region = dfs(matrix, x, y, visited, matrix[x][y])
        regions << region unless region.empty?
      end
    end
  end

  regions
end

# The area of a region is how many plots it contains
def calculate_area(region)
  region.length
end

# The perimeter of a region is the number of sides of plots it has that do not touch another garden plot in the same region
def calculate_perimeter(region)
  perimeter = 0

  region.each do |x, y|
    # Directions: right, left, down, up
    directions = [[0, 1], [0, -1], [1, 0], [-1, 0]]

    directions.each do |dx, dy|
      new_x, new_y = x + dx, y + dy

      # If the adjacent cell is not in the region, increment the perimeter
      perimeter += 1 if !region.include?([new_x, new_y])
    end
  end

  perimeter
end

regions = find_regions(matrix)

total_price = 0
regions.each do |region|
  total_price += calculate_area(region) * calculate_perimeter(region)
end

puts "Total price: #{total_price}"

# Part 2

# The number of sides is how many straight sections the
# garden plot has, regardless of length. We can use the
# number of corners to find this.
def calculate_sides(region)
  left = Set.new
  right = Set.new
  up = Set.new
  down = Set.new

  region.each do |r, c|
    up.add([r, c]) if !region.include?([r - 1, c])
    down.add([r, c]) if !region.include?([r + 1, c])
    right.add([r, c]) if !region.include?([r, c + 1])
    left.add([r, c]) if !region.include?([r, c - 1])
  end

  corners = 0

  up.each do |r, c|
    corners += 1 if left.include?([r, c])
    corners += 1 if right.include?([r, c])
    corners += 1 if right.include?([r - 1, c - 1]) && !left.include?([r,c])
    corners += 1 if left.include?([r - 1, c + 1]) && !right.include?([r,c])
  end

    down.each do |r, c|
    corners += 1 if left.include?([r, c])
    corners += 1 if right.include?([r, c])
    corners += 1 if right.include?([r + 1, c - 1]) && !left.include?([r,c])
    corners += 1 if left.include?([r + 1, c + 1]) && !right.include?([r,c])
  end

  corners
end

total_price = 0
regions.each do |region|
  total_price += calculate_area(region) * calculate_sides(region)
end

puts "Total bulk price: #{total_price}"