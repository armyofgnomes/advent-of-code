#!/usr/bin/env ruby
require 'set'

require_relative '../helpers/matrix'

# Part 1
file = File.read('2024/day-10/day-10-inputs.txt')
matrix = convert_to_matrix(file)

def find_trailheads(matrix)
  trailheads = []
  matrix.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      next if cell != "0"
      trailheads << [x, y]
    end
  end
  trailheads
end

def score_and_rate_trailheads(trailheads, matrix)
  score = 0
  rating = 0
  trailheads.each do |x, y|
    summits = Set.new
    rating += count_paths(matrix, x, y, 0, summits)
    score += summits.size
  end
  [score, rating]
end

def count_paths(matrix, x, y, current_value, summits)
  return 0 if x < 0 || y < 0 || y >= matrix.size || x >= matrix[0].size

  cell_value = matrix[y][x].to_i
  return 0 unless cell_value == current_value
  if cell_value == 9
    summits.add([x, y])
    return 1
  end

  total_paths = 0
  [[0, 1], [1, 0], [0, -1], [-1, 0]].each do |dx, dy|
    total_paths += count_paths(matrix, x + dx, y + dy, current_value + 1, summits)
  end

  total_paths
end

trailheads = find_trailheads(matrix)


score, rating = score_and_rate_trailheads(trailheads, matrix)
puts "Score: #{score}"
# Part 2
puts "Rating: #{rating}"