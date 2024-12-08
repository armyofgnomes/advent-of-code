def convert_to_matrix(file)
  matrix = []
  # Convert characters into a 2d matrix
  file.each_line.with_index do |line, y|
    line.chomp.each_char.with_index do |char, x|
      matrix[y] ||= []
      matrix[y][x] = char
    end
  end
  matrix
end