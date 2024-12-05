#!/usr/bin/env ruby

# Part 1
file = File.read('2024/day-05/day-05-inputs.txt')

rules, updates = file.split("\n\n")

invalid_updates = []
valid_updates = []
rules_map = {}
rules.split("\n").each do |line|
  rule, value = line.chomp.split("|")
  rules_map[rule] ||= []
  rules_map[rule] << value
end

updates.split("\n").each do |line|
  update = line.chomp.split(",")
  valid_update = update.all? do |u|
    index = update.index(u)
    valid = rules_map[u].nil? || rules_map[u].all? do |value|
      update.index(value).nil? || index < update.index(value)
    end
    valid
  end
  if valid_update
    valid_updates << update
  else
    invalid_updates << update
  end
end

sum = valid_updates.sum do |update|
  middle_value = update.at(update.size / 2)
  middle_value.to_i
end

puts "Sum of valid updates middle value: #{sum}"

# Part 2
fixed_updates = []
invalid_updates.each do |update|
  fixed = update.sort do |a, b|
    if rules_map[a].nil?
      0
    elsif rules_map[a].include?(b)
      1
    else
      -1
    end
  end

  fixed_updates << fixed
end

sum = fixed_updates.sum do |update|
  middle_value = update.at(update.size / 2)
  middle_value.to_i
end
puts "Sum of fixed updates middle value: #{sum}"
