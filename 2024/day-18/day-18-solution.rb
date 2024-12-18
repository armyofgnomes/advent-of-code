#!/usr/bin/env ruby

HEIGHT = 71
WIDTH = 71
SIMULATION_STEPS = 1024

file = File.read('2024/day-18/day-18-inputs.txt')
bytes = file.split("\n").map{ |line| line.split(',') }
matrix = Array.new(HEIGHT) { Array.new(WIDTH, '.') }

bytes.first(SIMULATION_STEPS).each do |byte|
  x, y = byte.map(&:to_i)
  matrix[y][x] = '#'
end

def draw_map(matrix)
  matrix.each do |row|
    puts row.join
  end
end


# Use Dijkstra's to find shortest path from 0,0 to WIDTH-1, HEIGHT-1
# If no path is found, raise an error
def map_path(matrix)
  start = [0, 0]
  goal = [WIDTH - 1, HEIGHT - 1]
  matrix = matrix.map(&:dup)

  queue = [[0, start]]
  visited = Set.new
  distances = Hash.new(Float::INFINITY)
  distances[start] = 0
  path = {}

  until queue.empty?
    current_cost, current = queue.shift
    visited.add(current)
    break if current == goal

    neighbors = [
      [current[0] + 1, current[1]],
      [current[0] - 1, current[1]],
      [current[0], current[1] + 1],
      [current[0], current[1] - 1]
    ]

    neighbors.each do |neighbor|
      next if visited.include?(neighbor)
      next unless neighbor[0].between?(0, WIDTH - 1) && neighbor[1].between?(0, HEIGHT - 1)
      next if matrix[neighbor[1]][neighbor[0]] == '#'

      new_cost = current_cost + 1
      if new_cost < distances[neighbor]
        distances[neighbor] = new_cost
        queue.push([new_cost, neighbor])
        path[neighbor] = current
      end
    end
  end

  # Raise error if goal wasn't reached
  raise "No path found to goal" unless path.key?(goal)

  # Backtrack to find all positions in best paths
  visited_positions = Set.new
  current = goal
  until current == start
    visited_positions.add(current)
    current = path[current]
  end
  visited_positions.add(start)

  visited_positions.each do |x, y|
    matrix[y][x] = 'O'
  end
  matrix
end

def path_length(matrix)
  matrix.flatten.count('O') - 1 # Subtract 1 because the start position is included
end

def reset_path(matrix)
  matrix = matrix.map(&:dup)
  matrix.map do |row|
    row.map do |cell|
      cell == 'O' ? '.' : cell
    end
  end
  matrix
end

map = map_path(matrix)
draw_map(map)

# Part 1
puts "Path length: #{path_length(map)} steps"

# Part 2 - Determine first byte to block path to exit
file = File.read('2024/day-18/day-18-inputs.txt')
bytes = file.split("\n").map{ |line| line.split(',') }
matrix = Array.new(HEIGHT) { Array.new(WIDTH, '.') }

bytes.each do |byte|
  x, y = byte.map(&:to_i)
  matrix[y][x] = '#'
  begin
    matrix = map_path(matrix)
    draw_map(matrix)
  rescue
    puts "Byte #{x},#{y} blocks path"
    break
  end

  matrix = reset_path(matrix)
end