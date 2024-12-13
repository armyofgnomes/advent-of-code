#!/usr/bin/env ruby

# Part 1
file = File.read('2024/day-13/day-13-inputs.txt')

# Sample input
# Button A: X+94, Y+34
# Button B: X+22, Y+67
# Prize: X=8400, Y=5400

def parse_machines(file)
  machines = []
  current_machine = {}

  button_match = /X\+(\d+), Y\+(\d+)/
  file.each_line do |line|
    line = line.chomp
    if line =~ /Button A/
      current_machine[:button_a] = line.match(button_match).captures.map(&:to_i)
    elsif line =~ /Button B/
      current_machine[:button_b] = line.match(button_match).captures.map(&:to_i)
    elsif line =~ /Prize/
      current_machine[:prize] = line.match(/X=(\d+), Y=(\d+)/).captures.map(&:to_i)
      machines << current_machine
      current_machine = {}
    end
  end

  machines
end

def solve_machine(button_a, button_b, prize, part_2: false)
  x1, y1 = button_a
  x2, y2 = button_b
  x0, y0 = prize

  if part_2
    x0 += 10000000000000
    y0 += 10000000000000
  end

  # Linear algebra
  # a * x1 + b * x2 = x0
  # a * y1 + b * y2 = y0

  determinant = x1 * y2 - x2 * y1

  return nil if determinant.zero?  # No solution if determinant is zero

  # Calculate initial solutions
  a_numerator = x0 * y2 - x2 * y0
  b_numerator = x1 * y0 - x0 * y1

  if a_numerator % determinant != 0 || b_numerator % determinant != 0
    return nil  # No integer solutions
  end

  a_presses = a_numerator / determinant
  b_presses = b_numerator / determinant

  if a_presses < 0 || b_presses < 0
    return nil
  end

  # Calculate cost: 3 tokens for a, 1 for b
  cost = 3 * a_presses + 1 * b_presses

  { a: a_presses, b: b_presses, cost: cost }
end

def solve_machines(machines, part_2: false)
  total_cost = 0

  machines.each do |machine|
    result = solve_machine(machine[:button_a], machine[:button_b], machine[:prize], part_2:)
    if result
      total_cost += result[:cost]
    end
  end

  total_cost
end

machines = parse_machines(file)
puts "Fewest tokens required: #{solve_machines(machines)}"

# Part 2
puts "Error corrected fewest tokens required: #{solve_machines(machines, part_2: true)}"
