#!/usr/bin/env ruby

# Part 1
def backtrack(index:, numbers:, target_val:, curr_total: 0, concat: false)
  # Base case, end of the array
  return curr_total == target_val if index == numbers.length

  # Try adding the next number
  if backtrack(index: index + 1, target_val:, numbers:, curr_total: curr_total + numbers[index], concat:)
    return true
  end

  # Try multiplying the next number
  if backtrack(index: index + 1, target_val:, numbers:, curr_total: curr_total * numbers[index], concat:)
    return true
  end

  # Try concatenating the next number
  if concat && backtrack(index: index + 1, target_val:, numbers:, curr_total: "#{curr_total}#{numbers[index]}".to_i, concat:)
    return true
  end

  return false
end

def test_vals(concat: false)
  file = File.read('2024/day-07/day-07-inputs.txt')

  valid_vals = []
  file.each_line do |line|
    test_val, params = line.split(":")
    params = params.split(" ").map(&:to_i)
    valid_vals << test_val.to_i if backtrack(index: 0, numbers: params, target_val: test_val.to_i, concat:)
  end

  valid_vals
end

puts "Sum of test values: #{test_vals.sum}"

# Part 2 - Add concatenation operation
puts "Sum of test values: #{test_vals(concat: true).sum}"