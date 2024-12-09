#!/usr/bin/env ruby

# Part 1

# Map out free and used blocks
def map_blocks(file)
  file_index = 0
  blocks = []
  file.each_char.with_index do |block, i|
    block = block.to_i
    block.times do
      if i % 2 == 0 || i == 0
        blocks << file_index
      else
        blocks << "."
      end
    end
    file_index += 1 if i % 2 == 0 || i == 0
  end
  blocks
end

# Compact blocks
def compact_blocks(blocks)
  blocks = blocks.dup
  r_index = blocks.size - 1
  blocks.size.times do |l_index|
    char = blocks[l_index]
    next unless char == "."

    while blocks[r_index] == "."
      r_index -= 1
    end

    break if l_index >= r_index

    # Swap chars at left index and right index
    blocks[l_index], blocks[r_index] = blocks[r_index], blocks[l_index]
  end
  blocks
end

# Calculate checksum
def calculate_checksum(blocks)
  checksum = 0
  blocks.each_with_index do |block, i|
    next if block == '.'
    checksum += i * block
  end
  checksum
end

file = File.read('2024/day-09/day-09-inputs.txt')
blocks = map_blocks(file)
compact_blocks = compact_blocks(blocks)

puts "Checksum: #{calculate_checksum(compact_blocks)}"

# Part 2
def compact_files(blocks)
  blocks = blocks.dup

  # Map out free space regions (start and length)
  free_spaces = []
  i = 0
  while i < blocks.size
    if blocks[i] == "."
      start = i
      while i < blocks.size && blocks[i] == "."
        i += 1
      end
      length = i - start
      free_spaces << {start: start, length: length}
    else
      i += 1
    end
  end

  # Start with rightmost position
  right = blocks.size - 1

  while right >= 0
    # Skip dots from right
    while right >= 0 && blocks[right] == "."
      right -= 1
    end
    break if right < 0

    # Find block size
    block_end = right
    block_char = blocks[right]
    while right > 0 && blocks[right - 1] == block_char
      right -= 1
    end
    block_size = block_end - right + 1

    # Look for leftmost free space that fits
    free_spaces.each do |space|
      if space[:length] >= block_size && space[:start] <= right
        # Move block into free space
        block_size.times do |offset|
          blocks[space[:start] + offset] = block_char
          blocks[right + offset] = "."
        end
        # Update free spaces
        if space[:length] == block_size
          free_spaces.delete(space)
        else
          space[:start] += block_size
          space[:length] -= block_size
        end
        break
      end
    end

    right -= 1
  end

  blocks
end

compact_file_blocks = compact_files(blocks)
puts "Checksum: #{calculate_checksum(compact_file_blocks)}"
