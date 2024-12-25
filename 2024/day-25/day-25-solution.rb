#!/usr/bin/env ruby
# frozen_string_literal: true
require_relative '../helpers/matrix'

# Part 1
file = File.read('2024/day-25/day-25-inputs.txt')

def lock_or_key?(schematic)
  if schematic[0].all? { |cell| cell == '#' }
    :lock
  else
    :key
  end
end

# Count number of # in each column
def calculate_heights(schematic)
  heights = []
  schematic[0].size.times do |col|
    count = schematic.sum { |row| row[col] == '#' ? 1 : 0 }
    heights << (count > 0 ? count - 1 : 0)
  end
  heights
end

def key_fits_lock?(key_heights, lock_heights, max_height)
  key_heights.each_with_index do |key_height, i|
    lock_height = lock_heights[i]
    return false if key_height + lock_height > max_height
  end
  true
end

locks = []
keys = []
max_height = 0
locks_and_keys = file.split("\n\n")

locks_and_keys.each do |schematic|
  schematic = convert_to_matrix(schematic)
  max_height = schematic[0].size
  if lock_or_key?(schematic) == :lock
    locks << schematic
  else
    keys << schematic
  end
end

key_heights = keys.map { |key| calculate_heights(key) }
lock_heights = locks.map { |lock| calculate_heights(lock) }

pairs = []
lock_heights.each do |lock|
  key_heights.each do |key|
    if key_fits_lock?(key, lock, max_height)
      pairs << [key, lock]
    end
  end
end

puts "Unique combinations: #{pairs.size}"