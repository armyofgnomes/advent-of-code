#!/usr/bin/env ruby

# Part 1
file = File.read('2024/day-11/day-11-inputs.txt')

stones = file.split(" ").map(&:to_i)

def blink_stones(stones, number_of_times = 25)
  # Rules:
  # 1. If the stone is engraved with the number 0, it is replaced
  # by a stone engraved with the number 1.
  # 2. If the stone is engraved with a number that has an even number
  # of digits, it is replaced by two stones. The left half of the
  # digits are engraved on the new left stone, and the right half
  # of the digits are engraved on the new right stone.
  # (The new numbers don't keep extra leading zeroes: 1000 would
  # become stones 10 and 0.)
  # 3. If none of the other rules apply, the stone is replaced by a
  # new stone; the old stone's number multiplied by 2024 is
  # engraved on the new stone.
  tally = stones.tally
  number_of_times.times do
    new_tally = Hash.new(0)

    tally.each do |stone, n|
      case
      when stone == 0
        new_tally[1] += n
      when stone.digits.length.even?
        digits = stone.to_s
        new_tally[digits[0,digits.size/2].to_i] += n
        new_tally[digits[digits.size/2..].to_i] += n
      else
        new_tally[stone * 2024] += n
      end
    end

    tally = new_tally
  end
  tally.values.sum
end

puts "Part 1 number of stones: #{blink_stones(stones)}"

# Part 2
puts "Part 2 number of stones: #{blink_stones(stones, 75)}"