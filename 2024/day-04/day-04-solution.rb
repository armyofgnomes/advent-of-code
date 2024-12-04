#!/usr/bin/env ruby

# Part 1, find all occurrences of XMAS
file = File.read('2024/day-04/day-04-inputs.txt')

matrix = []
# Convert characters into a 2d matrix
file.each_line.with_index do |line, y|
  line.chomp.each_char.with_index do |char, x|
    matrix[y] ||= []
    matrix[y][x] = char
  end
end

def count_occurrences(matrix)
  word = "XMAS"
  word_length = word.length
  word_regex = /(?:#{word}|#{word.reverse})/
  count = 0

  directions = [
    [->(y, i) { y }, ->(x, i) { x + i }],     # horizontal
    [->(y, i) { y + i }, ->(x, i) { x }],     # vertical
    [->(y, i) { y + i }, ->(x, i) { x + i }], # diagonal
    [->(y, i) { y + i }, ->(x, i) { x - i }]  # reverse diagonal
  ]

  matrix.each_with_index do |row, y|
    row.each_with_index do |char, x|
      directions.each do |y_proc, x_proc|
        # Check if we have enough space in this direction
        next if y_proc[y, word_length - 1] >= matrix.size ||
                        x_proc[x, word_length - 1] >= row.size ||
                        x_proc[x, word_length - 1] < 0

        word = (0...word_length).map do |i|
            matrix[y_proc[y, i]][x_proc[x, i]]
        end.join

        count += 1 if word.match?(word_regex)
      end
    end
  end

  count
end

puts "Number of XMAS: #{count_occurrences(matrix)}"

# Part 2, find all X shaped MAS
def count_x_shaped(matrix)
  count = 0
  word = "MAS"
  regex = /(?:#{word}|#{word.reverse})/

  matrix.each_with_index do |row, y|
    row.each_with_index do |char, x|
      next unless char == 'A'

      # Check if we have enough space in all directions
      next if y - 1 < 0 || y + 1 >= matrix.size ||
              x - 1 < 0 || x + 1 >= row.size

      top_left = matrix[y - 1][x - 1]
      top_right = matrix[y - 1][x + 1]
      bottom_left = matrix[y + 1][x - 1]
      bottom_right = matrix[y + 1][x + 1]

      diagonal = "#{top_left}A#{bottom_right}"
      reverse_diagonal = "#{top_right}A#{bottom_left}"

      if diagonal.match(regex) && reverse_diagonal.match(regex)
        count += 1
      end
    end
  end

  count
end

puts "Number of X shaped MAS: #{count_x_shaped(matrix)}"
