#!/usr/bin/env ruby

# Part 1, scan for all mul operations and sum the results
file = File.read('2024/day-03/day-03-inputs.txt')

operations = file.scan(/mul\(\d{1,3},\d{1,3}\)/m)
sum = operations.sum do |o|
  o.scan(/\d{1,3}/).map(&:to_i).reduce(:*)
end
puts "Sum of operations: #{sum}"

# Part 2, scan for enabled mul operations and sum the results
operations = file.scan(/(?:mul\(\d{1,3},\d{1,3}\))|(?:do\(\))|(?:don't\(\))/m)
sum = 0
enabled = true

operations.each do |o|
  if o =~ /do\(\)/
    enabled = true
  elsif o =~ /don't\(\)/
    enabled = false
  else
    sum += o.scan(/\d{1,3}/).map(&:to_i).reduce(:*) if enabled
  end
end
puts "Sum of enabled operations: #{sum}"
