#!/usr/bin/env ruby

# Part 1
file = File.read('2024/day-06/day-06-inputs.txt')

matrix = []
# Convert characters into a 2d matrix
file.each_line.with_index do |line, y|
  line.chomp.each_char.with_index do |char, x|
    matrix[y] ||= []
    matrix[y][x] = char
  end
end

initial_pos = nil
matrix.each.with_index do |line, y|
  line.each.with_index do |char, x|
    if char =~ /\^/
      initial_pos = [x, y]
      break
    end
  end
end

def walk_matrix(matrix, start_pos, test_obs = nil)
  curr_pos = start_pos
  direction = [0, -1] # up
  visited = { curr_pos => true }
  # loop detector
  visited_directions = {[curr_pos, direction] => true}
  next_pos = [curr_pos[0] + direction[0], curr_pos[1] + direction[1]]

  # if we leave the area we are done
  while curr_pos[0] >= 0 && curr_pos[1] >= 0 && curr_pos[0] < matrix[0].size && curr_pos[1] < matrix.size
    next_pos = [curr_pos[0] + direction[0], curr_pos[1] + direction[1]]
    visited[curr_pos] = true
    visited_directions[[curr_pos, direction]] = true

    # looping
    if visited_directions.include?([next_pos, direction])
      return {}
    end

    if next_pos[0] < 0 || next_pos[1] < 0 || next_pos[0] >= matrix[0].size || next_pos[1] >= matrix.size
      break
    end

    next_char = matrix[next_pos[1]][next_pos[0]]

    if next_char =~ /#/ || test_obs == next_pos # obstacle, rotate 90 degrees clockwise
      direction =
        case direction
        when [0, -1] then [1, 0]   # up -> right
        when [1, 0] then [0, 1]    # right -> down
        when [0, 1] then [-1, 0]   # down -> left
        when [-1, 0] then [0, -1]  # left -> up
        end
    else
      curr_pos = next_pos
    end
  end
  visited.map(&:first).uniq
end

puts "Steps: #{walk_matrix(matrix, initial_pos).size}"

# Part 2, how many unique loops can we create by adding obstacles
def count_loops(matrix, start_pos)
  valid_positions = walk_matrix(matrix, start_pos)
  valid_positions.count do |test_pos|
    next false if test_pos == start_pos
    walk_matrix(matrix, start_pos, test_pos).empty?
  end
end

puts "Unique loops: #{count_loops(matrix, initial_pos)}"