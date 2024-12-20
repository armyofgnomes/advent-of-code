#!/usr/bin/env ruby

require_relative '../helpers/matrix'

file = File.read('2024/day-20/day-20-inputs.txt')
matrix = convert_to_matrix(file)

def draw_map(matrix)
  matrix.each do |row|
    puts row.join
  end
end

def find_in_matrix(matrix, char)
  matrix.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      return [x, y] if cell == char
    end
  end
end

def find_shortest_path(matrix, start, finish, cache = {})
  # Check cache first
  cache_key = [start, finish]
  return cache[cache_key] if cache.key?(cache_key)

  distances = { start => 0 }
  previous = {}
  queue = [start]

  until queue.empty?
    current = queue.shift
    x, y = current
    neighbors = [
      [x, y - 1],
      [x, y + 1],
      [x - 1, y],
      [x + 1, y]
    ]
    neighbors.each do |neighbor|
      nx, ny = neighbor
      next if ny < 0 || ny >= matrix.size
      next if nx < 0 || nx >= matrix[0].size
      next if matrix[ny][nx] == '#'
      new_cost = distances[current] + 1
      if !distances.key?(neighbor) || new_cost < distances[neighbor]
        distances[neighbor] = new_cost
        previous[neighbor] = current
        queue.push(neighbor)
      end
    end
  end

  # Reconstruct the path
  path = []
  current = finish
  while current
    path.unshift(current)
    current = previous[current]
  end

  # Cache the result before returning
  cache[cache_key] = path
  path
end

def complete_race(matrix)
  start = find_in_matrix(matrix, 'S')
  finish = find_in_matrix(matrix, 'E')
  find_shortest_path(matrix, start, finish)
end

def find_distances(matrix, finish)
  dist_map = {}
  visited = {}
  queue = [[finish, 0]]
  height = matrix.length
  width = matrix[0].length

  until queue.empty?
    (pos, dist) = queue.shift
    x, y = pos
    next if visited[pos]
    visited[pos] = true
    dist_map[pos] = dist

    [[x + 1, y],[x - 1, y],[x, y + 1],[x, y - 1]].each do |nx, ny|
      next if nx < 0 || ny < 0 || ny >= height || nx >= width
      next if matrix[ny][nx] == '#'
      queue << [[nx, ny], dist + 1]
    end
  end
  dist_map
end

# Find all shortcuts along the best path if we disable a wall
def find_cheats(matrix, base_path, max_cheat = 2)
  cheats = []
  finish = base_path.last
  # Precompute distances once
  dist_map = find_distances(matrix, finish)

  base_path.each_with_index do |pos, idx|
    next if idx == base_path.length - 1
    x, y = pos

    # Check all positions within max_cheat distance
    (-max_cheat..max_cheat).each do |dx|
      (-max_cheat..max_cheat).each do |dy|
        next if dx.abs + dy.abs > max_cheat # Manhattan distance check
        nx, ny = x + dx, y + dy
        next if ny < 0 || ny >= matrix.length || nx < 0 || nx >= matrix[0].length
        next if matrix[ny][nx] == '#' # We can only land on a free space
        dist = dist_map[[nx, ny]]
        next if dist.nil?

        # Calculate time saved
        manhattan_distance = dx.abs + dy.abs
        original_time = base_path.length - 1
        new_time = dist + idx + manhattan_distance
        cheats << new_time if new_time < original_time
      end
    end
  end
  cheats
end

draw_map(matrix)

paths = complete_race(matrix)
baseline = paths.count - 1

puts "Race completed regularly in #{baseline} picoseconds"

min_time_saved = 100
[2, 20].each do |cheat|
  cheats = find_cheats(matrix, paths, cheat)
  big_cheats = cheats.select { |time| time <= (baseline - min_time_saved) }.count

  puts "#{big_cheats} #{cheat} picosecond cheats save #{min_time_saved} seconds or more"
end