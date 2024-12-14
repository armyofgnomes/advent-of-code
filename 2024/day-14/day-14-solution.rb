#!/usr/bin/env ruby

# Part 1
file = File.read('2024/day-14/day-14-inputs.txt')

ROOM_WIDTH = 101
ROOM_HEIGHT = 103

def parse_robot_start_positions(file)
  robots = []
  file.each_line.map do |line|
    robot = {}
    match_regex = /([-\d]+,[-\d]+)/
    convert_positions = ->(match) { match.split(',').map(&:to_i) }
    robot[:position] = convert_positions.call(line.match(/p=#{match_regex}/)[1])
    robot[:velocity] = convert_positions.call(line.match(/v=#{match_regex}/)[1])
    robots << robot
  end
  robots
end

def calculate_robot_positions_after_seconds(robots, seconds)
  # Robot positions must wrap if they are greater than the room width or height
  robots.map do |robot|
    x, y = robot[:position]
    vx, vy = robot[:velocity]
    x = (x + vx * seconds) % ROOM_WIDTH
    y = (y + vy * seconds) % ROOM_HEIGHT
    { position: [x, y], velocity: [vx, vy] }
  end
end

def count_robots_in_each_quadrant(robots)
  quadrants = Array.new(4, 0)
  robots.each do |robot|
    x, y = robot[:position]
    # We ignore robots in the exact middle of the room
    if x < ROOM_WIDTH / 2
      if y < ROOM_HEIGHT / 2
        quadrants[0] += 1
      elsif y > ROOM_HEIGHT / 2
        quadrants[2] += 1
      end
    elsif x > ROOM_WIDTH / 2
      if y < ROOM_HEIGHT / 2
        quadrants[1] += 1
      elsif y > ROOM_HEIGHT / 2
        quadrants[3] += 1
      end
    end
  end
  quadrants
end

robots = parse_robot_start_positions(file)
robots = calculate_robot_positions_after_seconds(robots, 100)
quadrants = count_robots_in_each_quadrant(robots)
safety_score = quadrants.inject(:*)

puts "Safety score: #{safety_score}"

# Part 2 - When do the robots arrange into a Christmas tree

def draw_robot_positions(robots)
  room = Array.new(ROOM_HEIGHT) { Array.new(ROOM_WIDTH, '.') }
  robots.each do |robot|
    x, y = robot[:position]
    room[y][x] = '#'
  end
  room.each do |row|
    puts row.join
  end
end

def count_max_adjacent_robots(robots)
  # Group robots by y-coordinate
  robots_by_y = robots.group_by { |robot| robot[:position][1] }

  max_adjacent_robots = 0

  robots_by_y.each do |_y, row_robots|
    # Sort robots by x-coordinate
    sorted_x = row_robots.map { |robot| robot[:position][0] }.sort
    current_count = 1

    # Check adjacent positions
    (0...sorted_x.length - 1).each do |i|
      if sorted_x[i + 1] - sorted_x[i] == 1
        current_count += 1
      else
        max_adjacent_robots = [max_adjacent_robots, current_count].max
        current_count = 1
      end
    end
    max_adjacent_robots = [max_adjacent_robots, current_count].max
  end

  max_adjacent_robots
end

robots = parse_robot_start_positions(file)
seconds = 1
loop do
  robots = calculate_robot_positions_after_seconds(robots, 1)
  if count_max_adjacent_robots(robots) > 10
    puts "Tree found at: #{seconds}"
    puts "*" * ROOM_WIDTH
    draw_robot_positions(robots)
    puts "*" * ROOM_WIDTH
    break
  end
  seconds += 1
end