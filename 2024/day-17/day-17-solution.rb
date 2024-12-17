#!/usr/bin/env ruby

class Computer
  def initialize(registers, program)
    @registers = registers || {}
    @instruction_pointer = 0
    @program = program
    @output = []
  end

  def set_register(register, value)
    @registers[register] = value
  end

  def get_register(register)
    @registers[register]
  end

  def advance_instruction_pointer
    @instruction_pointer += 2
  end

  # Combo operands 0 through 3 represent literal values 0 through 3.
  # Combo operand 4 represents the value of register A.
  # Combo operand 5 represents the value of register B.
  # Combo operand 6 represents the value of register C.
  # Combo operand 7 is reserved and will not appear in valid programs.
  def combo_operand(operand)
    case operand
    when 0..3
      operand
    when 4
      get_register(:a)
    when 5
      get_register(:b)
    when 6
      get_register(:c)
    when 7
      raise "Invalid combo operand: #{operand}"
    end
  end

  # The adv instruction (opcode 0) performs division.
  # The numerator is the value in the A register.
  # The denominator is found by raising 2 to the
  # power of the instruction's combo operand.
  # (So, an operand of 2 would divide A by 4 (2^2);
  # an operand of 5 would divide A by 2^B.)
  # The result of the division operation is truncated
  # to an integer and then written to the A register.
  def adv(operand)
    numerator = get_register(:a)
    denominator = 2 ** combo_operand(operand)
    set_register(:a, numerator / denominator)
  end

  # The bxl instruction (opcode 1) calculates the
  # bitwise XOR of register B and the instruction's
  # literal operand, then stores the result in register B.
  def bxl(operand)
    bitwise_xor = get_register(:b) ^ operand
    set_register(:b, bitwise_xor)
  end

  # The bst instruction (opcode 2) calculates the value of
  # its combo operand modulo 8 (thereby keeping only its
  # lowest 3 bits), then writes that value to the B register.
  def bst(operand)
    set_register(:b, combo_operand(operand) % 8)
  end

  # The jnz instruction (opcode 3) does nothing if the A register
  # is 0. However, if the A register is not zero, it jumps by
  # setting the instruction pointer to the value of its literal
  # operand; if this instruction jumps, the instruction pointer
  # is not increased by 2 after this instruction.
  def jnz(operand)
    return if get_register(:a) == 0

    @instruction_pointer = operand
  end

  # The bxc instruction (opcode 4) calculates the bitwise XOR
  # of register B and register C, then stores the result in register B.
  # (For legacy reasons, this instruction reads an operand but ignores it.)
  def bxc(operand)
    bitwise_xor = get_register(:b) ^ get_register(:c)
    set_register(:b, bitwise_xor)
  end

  # The out instruction (opcode 5) calculates the value of its
  # combo operand modulo 8, then outputs that value.
  # (If a program outputs multiple values, they are separated by commas.)
  def out(operand)
    @output << combo_operand(operand) % 8
  end

  # The bdv instruction (opcode 6) works exactly like the
  # adv instruction except that the result is stored in the
  # B register. (The numerator is still read from the A register.)
  def bdv(operand)
    numerator = get_register(:a)
    denominator = 2 ** combo_operand(operand)
    set_register(:b, numerator / denominator)
  end

  # The cdv instruction (opcode 7) works exactly like the
  # adv instruction except that the result is stored in the
  # C register. (The numerator is still read from the A register.)
  def cdv(operand)
    numerator = get_register(:a)
    denominator = 2 ** combo_operand(operand)
    set_register(:c, numerator / denominator)
  end

  def execute_instruction(opcode, operand)
    case opcode
    when 0
      adv(operand)
    when 1
      bxl(operand)
    when 2
      bst(operand)
    when 3
      jnz(operand)
    when 4
      bxc(operand)
    when 5
      out(operand)
    when 6
      bdv(operand)
    when 7
      cdv(operand)
    else
      raise "Unknown opcode: #{opcode}"
    end
    advance_instruction_pointer unless opcode == 3 && get_register(:a) != 0
    true
  end

  def run
    while @instruction_pointer < @program.length
      opcode = @program[@instruction_pointer]
      operand = @program[@instruction_pointer + 1]
      # puts "Executing instruction: #{opcode} #{operand}"
      execute_instruction(opcode, operand)
    end
    @output
  end
end

file = File.read('2024/day-17/day-17-inputs.txt')

registers = { a: 0, b: 0, c: 0 }
program = nil

file.each_line do |line|
  if line.start_with?("Register A")
    registers[:a] = line.split(' ')[2].to_i
  elsif line.start_with?("Register B")
    registers[:b] = line.split(' ')[2].to_i
  elsif line.start_with?("Register C")
    registers[:c] = line.split(' ')[2].to_i
  elsif line.start_with?('Program:')
    program = line.match(/Program: (.*)/)[1].split(',').map(&:to_i)
  end
end

computer = Computer.new(registers, program)
output = computer.run
puts "Program output: #{output.join(',')}"

# Part 2
a = 0
program.length.times do |n|
  target = program[program.length - n - 1..].clone
  new_a = a << 3

  loop do
    registers = { a: new_a, b: 0, c: 0 }
    computer = Computer.new(registers, program)
    output = computer.run

    if output == target
      a = new_a
      break
    end
    new_a += 1
  end
end

puts "Found match with register A value: #{a}"

