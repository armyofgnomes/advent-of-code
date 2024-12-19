#!/usr/bin/env ruby

file = File.read('2024/day-19/day-19-inputs.txt')

patterns, designs = file.split("\n\n")

patterns = patterns.split(", ")
designs = designs.split("\n")

def count_possible_patterns(patterns, design)
  memo = {}

  dfs = -> (design) {
    return 1 if design.empty?
    return memo[design] if memo.has_key?(design)

    count = 0
    patterns.each do |pattern|
      if design.start_with?(pattern)
        rest = design[pattern.length..]
        count += dfs[rest]
      end
    end
    memo[design] = count
    count
  }

  dfs[design]
end

puts "Number of possible designs: #{designs.count { |design| count_possible_patterns(patterns, design) != 0 }}"

# Part 2 - Count the number of ways each design can be created
puts "Number of ways each possible design can be created: #{designs.sum { |design| count_possible_patterns(patterns, design) }}"
