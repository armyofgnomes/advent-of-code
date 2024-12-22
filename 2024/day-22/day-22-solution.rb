#!/usr/bin/env ruby
# frozen_string_literal: true

# Calculate the result of multiplying the secret number by 64.
# Then, mix this result into the secret number.
# Finally, prune the secret number.
# Calculate the result of dividing the secret number by 32.
# Round the result down to the nearest integer.
# Then, mix this result into the secret number.
# Finally, prune the secret number.
# Calculate the result of multiplying the secret number by 2048.
# Then, mix this result into the secret number.
# Finally, prune the secret number.

# To mix a value into the secret number, calculate the
# bitwise XOR of the given value and the secret number.
# Then, the secret number becomes the result of that operation.
# (If the secret number is 42 and you were to mix 15 into the
# secret number, the secret number would become 37.)
# To prune the secret number, calculate the value of the secret
# number modulo 16777216. Then, the secret number becomes the
# result of that operation. (If the secret number is 100000000
# and you were to prune the secret number, the secret number
# would become 16113920.)

class SecretNumber
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def mix(value)
    @value = @value ^ value
  end

  def prune
    @value = @value % 16777216
  end

  def step_1
    mix(@value * 64)
    prune
  end

  def step_2
    mix((@value / 32).floor)
    prune
  end

  def step_3
    mix(@value * 2048)
    prune
  end

  def evolve
    step_1
    step_2
    step_3
  end

  def to_s
    @value.to_s
  end
end

file = File.read('2024/day-22/day-22-inputs.txt')
initial_numbers = file.split("\n")

sum = 0
initial_numbers.each do |initial_number|
  secret_number = SecretNumber.new(initial_number.to_i)
  2000.times do
    secret_number.evolve
  end
  sum += secret_number.value
  # puts "#{initial_number}: #{secret_number}"
end

# Part 1
puts "Sum: #{sum}"

# Part 2

# Track sequences of four consecutive price changes and their resulting prices
sequences = Hash.new { |h, k| h[k] = Hash.new(0) }

initial_numbers.each do |initial_number|
  secret_number = SecretNumber.new(initial_number.to_i)
  prev_price = secret_number.value % 10
  changes = []

  2000.times do
    secret_number.evolve
    current_price = secret_number.value % 10
    change = current_price - prev_price
    changes << change

    # Once we have 4 changes, record the sequence and the current price
    if changes.length >= 4
      seq = changes[-4..-1]
      key = seq.join(',')
      # Only record the first occurrence of the sequence for this buyer
      if !sequences[key].key?(initial_number)
        sequences[key][initial_number] = current_price
      end
    end

    prev_price = current_price
  end
end

# Find the sequence that gives the highest total bananas
best_sequence = sequences.max_by { |_, prices| prices.values.sum }
winning_sequence = best_sequence[0]
total_bananas = best_sequence[1].values.sum

puts "Best sequence of changes: #{winning_sequence}"
puts "Total bananas: #{total_bananas}"
