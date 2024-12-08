#!/usr/bin/env ruby

require_relative '../helpers/matrix'

# Part 1
file = File.read('2024/day-08/day-08-inputs.txt')

matrix = convert_to_matrix(file)

def find_antinodes(matrix, repeat: false)
  height = matrix.length
  width = matrix[0].length

  # Map of symbol -> array of positions
  towers = {}

  matrix.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      next if cell == '.'
      towers[cell] ||= []
      towers[cell] << [x, y]
    end
  end

  antinodes = Set.new

  # For each frequency that has multiple towers
  towers.each do |symbol, positions|
    next if positions.length < 2

    # Generate all pairs of towers
    positions.combination(2) do |tower1, tower2|
      x1, y1 = tower1
      x2, y2 = tower2

      if repeat
        antinodes.add([x1, y1])
        antinodes.add([x2, y2])
      end

      # Calculate distance vector between towers
      dx = x2 - x1
      dy = y2 - y1

      # Extend before first tower
      multiplier = 1
      loop do
        curr_x = x1 - (dx * multiplier)
        curr_y = y1 - (dy * multiplier)

        break unless curr_x >= 0 && curr_x < width &&
                    curr_y >= 0 && curr_y < height

        antinodes.add([curr_x, curr_y])
        break unless repeat
        multiplier += 1
      end

      # Extend after second tower
      multiplier = 1
      loop do
        curr_x = x2 + (dx * multiplier)
        curr_y = y2 + (dy * multiplier)

        break unless curr_x >= 0 && curr_x < width &&
                    curr_y >= 0 && curr_y < height

        antinodes.add([curr_x, curr_y])
        break unless repeat
        multiplier += 1
      end
    end
  end

  antinodes
end

puts "Unique antinodes: #{find_antinodes(matrix).size}"

# Part 2
puts "Repeated unique antinodes: #{find_antinodes(matrix, repeat: true).size}"
