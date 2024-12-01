#!/usr/bin/env ruby

# Part 1 - Calculate the sum of the absolute differences between the two columns
column_1 = []
column_2 = []
inputs = File.readlines('2024/day-01/day-01-inputs.txt').map do |line|
  arr = line.split(/\s+/).map(&:to_i)
  column_1 << arr[0]
  column_2 << arr[1]
end

column_1.sort!
column_2.sort!

sum = 0
column_1.each.with_index do |num, i|
  sum += (column_2[i] - num).abs
end

puts "Sum: #{sum}"

# Part 2 - Calculate the similarity score by multiplying
# the number of times each number in the left column appears in the right column
similarity = 0
column_1.each do |num|
  similarity += num * column_2.count(num)
end

puts "Similarity: #{similarity}"