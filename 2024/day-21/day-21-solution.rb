#!/usr/bin/env ruby
# frozen_string_literal: true

BFS_DIRECTIONS = {
  '^' => [0, -1],
  '>' => [1, 0],
  'v' => [0, 1],
  '<' => [-1, 0]
}.freeze

KEYPAD = {
  '7' => [0, 0], '8' => [1, 0], '9' => [2, 0],
  '4' => [0, 1], '5' => [1, 1], '6' => [2, 1],
  '1' => [0, 2], '2' => [1, 2], '3' => [2, 2],
  '.' => [0, 3], '0' => [1, 3], 'A' => [2, 3]
}.freeze

DIRECTIONS = {
  '.' => [0, 0], '^' => [1, 0], 'A' => [2, 0],
  '<' => [0, 1], 'v' => [1, 1], '>' => [2, 1]
}.freeze

def get_command(keypad, start, target)
  return ['A'] if start == target

  queue = [[keypad[start], '']]
  distances = {}
  all_paths = []

  until queue.empty?
    pos, path = queue.shift
    if pos == keypad[target]
      all_paths << "#{path}A"
      next
    end

    pos_key = pos.join(',')
    next if distances[pos_key] && distances[pos_key] < path.length

    BFS_DIRECTIONS.each do |direction, (dx, dy)|
      new_pos = [pos[0] + dx, pos[1] + dy]
      next if new_pos == keypad['.'] # Skip blank area

      # Check if position is valid (has a button)
      if keypad.values.include?(new_pos)
        new_path = path + direction
        new_pos_key = new_pos.join(',')
        if !distances[new_pos_key] || distances[new_pos_key] >= new_path.length
          queue << [new_pos, new_path]
          distances[new_pos_key] = new_path.length
        end
      end
    end
  end

  all_paths.sort_by(&:length)
end

def get_key_presses(keypad, code, robot_depth, memo = {})
  key = "#{code},#{robot_depth}"
  return memo[key] if memo[key]

  current = 'A'
  length = 0

  code.each_char do |target|
    moves = get_command(keypad, current, target)
    if robot_depth.zero?
      length += moves[0].length
    else
      length += moves.map { |move| get_key_presses(DIRECTIONS, move, robot_depth - 1, memo) }.min
    end
    current = target
  end

  memo[key] = length
  length
end

file = File.read('2024/day-21/day-21-inputs.txt')
codes = file.split("\n")

# Part 1
total = codes.sum do |code|
  numerical = code.gsub('A', '').to_i
  numerical * get_key_presses(KEYPAD, code, 2)
end
puts "Part 1 total complexity: #{total}"

# Part 2
total = codes.sum do |code|
  numerical = code.gsub('A', '').to_i
  numerical * get_key_presses(KEYPAD, code, 25)
end
puts "Part 2 total complexity: #{total}"
