#!/usr/bin/env ruby

require_relative '../helpers/matrix'

# Part 1
def build_map_matrix(map)
  convert_to_matrix(map)
end

def parse_command(command)
  case command
  when "^"
    [0, -1]
  when "v"
    [0, 1]
  when "<"
    [-1, 0]
  when ">"
    [1, 0]
  end
end

def parse_commands(commands)
  commands.gsub("\n", "").each_char.map do |command|
    parse_command(command)
  end
end

def draw_map(matrix)
  puts matrix.map { |row| row.join('') }.join("\n")
end

def can_move?(matrix, x, y)
  matrix[y][x] != "#"
end

def can_push_boxes?(matrix, x, y, dx, dy)
  return true if matrix[y][x] == "."
  return false if matrix[y][x] == "#"

  # Find both parts of box
  if dy != 0 && matrix[y][x].match(/[\[\]]/)
    left_x = matrix[y][x] == "[" ? x : x - 1
    right_x = left_x + 1

    # Check if both parts can move
    return false if matrix[y + dy][left_x] == "#" || matrix[y + dy][right_x] == "#"

    # If there are boxes ahead, check if they can move
    if matrix[y + dy][left_x].match(/[\[\]]/) || matrix[y + dy][right_x].match(/[\[\]]/)
      return can_push_boxes?(matrix, left_x, y + dy, dx, dy) &&
             can_push_boxes?(matrix, right_x, y + dy, dx, dy)
    end

    return true
  end

  # Horizontal movement
  new_y, new_x = y + dy, x + dx
  return false if matrix[new_y][new_x] == "#"
  return true if matrix[new_y][new_x] == "."
  can_push_boxes?(matrix, new_x, new_y, dx, dy)
end

def move_boxes(matrix, x, y, dx, dy)
  return true if !matrix[y][x].match(/[O\[\]]/)

  if dy != 0 && matrix[y][x].match(/[\[\]]/)
    # Find box parts
    left_x = matrix[y][x] == "[" ? x : x - 1
    right_x = left_x + 1
    return true if matrix[y][left_x] != "[" # Already processed

    # Move boxes ahead first
    if matrix[y + dy][left_x].match(/[\[\]]/) || matrix[y + dy][right_x].match(/[\[\]]/)
      move_boxes(matrix, left_x, y + dy, dx, dy)
      move_boxes(matrix, right_x, y + dy, dx, dy)
    end

    # Move current box
    if matrix[y + dy][left_x] == "." && matrix[y + dy][right_x] == "."
      matrix[y + dy][left_x] = "["
      matrix[y + dy][right_x] = "]"
      matrix[y][left_x] = "."
      matrix[y][right_x] = "."
    end
  else
    # Handle horizontal movement
    if matrix[y + dy][x + dx] == "."
      matrix[y + dy][x + dx] = matrix[y][x]
      matrix[y][x] = "."
    elsif matrix[y + dy][x + dx].match(/[\[\]]/)
      move_boxes(matrix, x + dx, y + dy, dx, dy)
      move_boxes(matrix, x, y, dx, dy)
    end
  end

  true
end

def move_robot(matrix, commands)
  matrix = matrix.dup.map(&:dup)
  # Find the robot's starting position (@)
  y = matrix.index { |row| row.include?("@") }
  x = matrix[y].index("@")
  robot_position = [x, y]

  commands.each do |command|
    x, y = robot_position
    dx, dy = command
    new_x = x + dx
    new_y = y + dy

    next unless can_move?(matrix, new_x, new_y)

    case matrix[new_y][new_x]
    when "."  # Empty space
      matrix[y][x] = "."
      matrix[new_y][new_x] = "@"
      robot_position = [new_x, new_y]
    when "O", "[", "]"  # Box
      # Check if all boxes in this direction can be pushed
      if can_push_boxes?(matrix, new_x, new_y, dx, dy)
        # Move all boxes starting from the furthest one
        move_boxes(matrix, new_x, new_y, dx, dy)
        # Move robot
        matrix[y][x] = "."
        matrix[new_y][new_x] = "@"
        robot_position = [new_x, new_y]
      end
    end
    # draw_map(matrix) # Uncommment to draw map
  end

  matrix
end

def find_box_coordinates(matrix)
  matrix.each_with_index.flat_map do |row, y|
    row.each_with_index.select { |cell, _| cell == "O" || cell == "[" }.map do |_, x|
      [x, y]
    end
  end
end

def calculate_box_coordinates_score(box_coordinates)
  box_coordinates.map { |x, y| (100 * y) + x }.sum
end

file = File.read('2024/day-15/day-15-inputs.txt')
map, commands = file.split("\n\n")

matrix = build_map_matrix(map)
commands = parse_commands(commands)

matrix = move_robot(matrix, commands)
box_coordinates = find_box_coordinates(matrix)

puts "GPS score: #{calculate_box_coordinates_score(box_coordinates)}"

# Part 2 - Twice as wide map
def enlarge_map(matrix)
  # Walls become ##
  # Empty spaces become ..
  # Boxes become []
  # Robot becomes @.
  enlarged = matrix.map do |row|
    row.map do |cell|
      case cell
      when "#" then "##"
      when "." then ".."
      when "O" then "[]"
      when "@" then "@."
      end
    end.join  # Join the doubled characters
  end

  # Convert strings back to character arrays
  enlarged.map { |row| row.chars }
end

# Part 2 specific methods

file = File.read('2024/day-15/day-15-inputs.txt')
map, commands = file.split("\n\n")

matrix = build_map_matrix(map)
commands = parse_commands(commands)

matrix = enlarge_map(matrix)

matrix = move_robot(matrix, commands)
box_coordinates = find_box_coordinates(matrix)

puts "Enlarged map GPS score: #{calculate_box_coordinates_score(box_coordinates)}"