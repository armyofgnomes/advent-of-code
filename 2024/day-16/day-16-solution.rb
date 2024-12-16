#!/usr/bin/env ruby
require 'algorithms'
require_relative '../helpers/matrix'

State = Struct.new(:x, :y, :direction, :cost, :path) do
  def to_key
    [x, y, direction]
  end
end

DIRS = {
  north: [0, -1],
  south: [0, 1],
  east: [1, 0],
  west: [-1, 0]
}.freeze

def find_shortest_path(matrix)
  start_pos = find_in_matrix(matrix, 'S')
  end_pos = find_in_matrix(matrix, 'E')

  queue = Containers::PriorityQueue.new
  queue.push(State.new(start_pos[0], start_pos[1], :east, 0), 0)
  seen = {}

  until queue.empty?
    current = queue.pop

    if [current.x, current.y] == end_pos
      return current.cost
    end

    key = current.to_key
    next if seen[key]
    seen[key] = true

    # Move forward
    dx, dy = DIRS[current.direction]
    nx, ny = current.x + dx, current.y + dy

    if valid_move?(matrix, nx, ny)
      new_state = State.new(nx, ny, current.direction, current.cost + 1)
      queue.push(new_state, -new_state.cost)
    end

    # Rotate left/right
    [:left, :right].each do |turn|
      new_dir = rotate(current.direction, turn)
      new_state = State.new(current.x, current.y, new_dir, current.cost + 1000)
      queue.push(new_state, -new_state.cost)
    end
  end
end

def draw_map(matrix, all_positions)
  result = matrix.map(&:dup)

  # Mark each position in best paths with 'O'
  all_positions.each do |x, y|
    # Skip walls and keep start/end markers
    next if matrix[y][x] == '#'
    next if matrix[y][x] == 'S' || matrix[y][x] == 'E'
    result[y][x] = 'O'
  end

  # Print the result
  result.each do |row|
    puts row.join
  end
end

def find_all_best_paths(matrix)
  start_pos = find_in_matrix(matrix, 'S')
  end_pos = find_in_matrix(matrix, 'E')

  queue = Containers::PriorityQueue.new
  start_state = State.new(start_pos[0], start_pos[1], :east, 0)
  queue.push(start_state, 0)
  distances = { [start_state.x, start_state.y, start_state.direction] => 0 }
  path = {}
  best_cost = nil
  backtrack_queue = []

  until queue.empty?
    current = queue.pop
    current_key = [current.x, current.y, current.direction]

    next if !best_cost.nil? && current.cost > best_cost

    if [current.x, current.y] == end_pos
      best_cost = current.cost
      backtrack_queue << current_key
      next
    end

    # Move forward
    dx, dy = DIRS[current.direction]
    nx, ny = current.x + dx, current.y + dy
    neighbor_key = [nx, ny, current.direction]
    if valid_move?(matrix, nx, ny)
      new_cost = current.cost + 1
      if !distances.key?(neighbor_key) || new_cost < distances[neighbor_key]
        distances[neighbor_key] = new_cost
        queue.push(State.new(nx, ny, current.direction, new_cost), -new_cost)
        path[neighbor_key] = [current_key]
      elsif new_cost == distances[neighbor_key]
        path[neighbor_key] << current_key
      end
    end

    # Rotate left/right
    [:left, :right].each do |turn|
      new_dir = rotate(current.direction, turn)
      neighbor_key = [current.x, current.y, new_dir]
      new_cost = current.cost + 1000
      if !distances.key?(neighbor_key) || new_cost < distances[neighbor_key]
        distances[neighbor_key] = new_cost
        queue.push(State.new(current.x, current.y, new_dir, new_cost), -new_cost)
        path[neighbor_key] = [current_key]
      elsif new_cost == distances[neighbor_key]
        path[neighbor_key] << current_key
      end
    end
  end

  # Backtrack to find all positions in best paths
  visited_positions = Set.new
  until backtrack_queue.empty?
    current_key = backtrack_queue.pop
    visited_positions.add([current_key[0], current_key[1]])
    prev_keys = path[current_key]
    backtrack_queue.concat(prev_keys) if prev_keys
  end

  draw_map(matrix, visited_positions)

  visited_positions.size
end

def rotate(direction, turn)
  rotations = {
    left: { north: :west, west: :south, south: :east, east: :north },
    right: { north: :east, east: :south, south: :west, west: :north }
  }
  rotations[turn][direction]
end

def valid_move?(matrix, x, y)
  matrix[y][x] != '#'
end

def find_in_matrix(matrix, char)
  matrix.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      return [x, y] if cell == char
    end
  end
end

file = File.read('2024/day-16/day-16-inputs.txt')
matrix = convert_to_matrix(file)
puts "Shortest path: #{find_shortest_path(matrix)}"

puts "Best paths: #{find_all_best_paths(matrix)}"