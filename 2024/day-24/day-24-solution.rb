#!/usr/bin/env ruby
# frozen_string_literal: true

# Part 1
class Wire
  attr_accessor :value
  attr_reader :name

  def initialize(name, value = nil)
    @name = name
    @value = value
  end
end

class Gate
  attr_reader :name, :input_wires, :output_wire

  def initialize(input_wires, output_wire)
    @input_wires = input_wires
    @name = output_wire.name
    @output_wire = output_wire
    output if output_wire.value.nil?
  end

  def output
    @output_wire.value
  end
end

class ANDGate < Gate
  def output
    @output_wire.value = @input_wires[0].value & @input_wires[1].value
  end
end

class ORGate < Gate
  def output
    @output_wire.value = @input_wires[0].value | @input_wires[1].value
  end
end

class XORGate < Gate
  def output
    @output_wire.value = @input_wires[0].value ^ @input_wires[1].value
  end
end

class System
  def initialize(wires = {})
    @gates = []
    @wires = wires
    @output = nil
  end

  def add_gate(gate)
    @gates << gate
  end

  def add_gates(gate_lines)
    unmapped_lines = []
    gate_match = /(?<input1>[\w\d]{3}) (?<type>AND|OR|XOR) (?<input2>[\w\d]{3}) -> (?<output>[\w\d]{3})/

    gate_lines.each do |gate_line|
      match = gate_line.match(gate_match)
      unless @wires.has_key?(match[:input1]) && @wires.has_key?(match[:input2])
        unmapped_lines << gate_line
        next
      end

      input1 = @wires[match[:input1]]
      input2 = @wires[match[:input2]]
      type = match[:type]
      output_name = match[:output]

      wire_gate(input1:, input2:, type:, output_name:)
    end

    # Keep looping until all lines are mapped
    while unmapped_lines.any?
      remaining_lines = []

      unmapped_lines.each do |gate_line|
        match = gate_line.match(gate_match)
        if @wires.has_key?(match[:input1]) && @wires.has_key?(match[:input2])
          input1 = @wires[match[:input1]]
          input2 = @wires[match[:input2]]
          type = match[:type]
          output_name = match[:output]

          wire_gate(input1:, input2:, type:, output_name:)
        else
          remaining_lines << gate_line
        end
      end

      # If no progress was made in mapping lines, we might have a circular dependency
      break if remaining_lines.size == unmapped_lines.size

      unmapped_lines = remaining_lines
    end
  end

  # Get output of all wires that start with Z
  def output
    values = @gates.select { |gate| gate.name.start_with?('z') }.sort_by(&:name).reverse.map(&:output)
    output ||= values.join
  end

  # Convert binary output to decimal value
  def to_d
    output.to_i(2)
  end

  # Part 2
  def find_swapped_wires
    swapped = []
    c0 = nil  # carry

    x_wires = @wires.keys.select { |w| w.start_with?('x') }.sort
    bits = x_wires.length

    bits.times do |i|
      n = format('%02d', i)
      x = "x#{n}"
      y = "y#{n}"

      # Find gates connected to these inputs
      z1, c1 = find_full_adder_wires(x, y, c0, swapped)

      # Check if carry wire starts with 'z' (except special case)
      if c1&.start_with?('z') && c1 != 'z45'
        c1, z1 = z1, c1
        swapped.concat([c1, z1])
      end

      # Update carry for next iteration
      c0 = c1 || find_gate_output(x, y, 'AND')
    end

    swapped.sort.join(',')
  end

  private

  def find_gate_output(input1, input2, operation)
    @gates.find do |gate|
      gate.is_a?(Object.const_get("#{operation}Gate")) &&
        gate.input_wires.map(&:name).sort == [input1, input2].sort
    end&.name
  end

  def find_full_adder_wires(x, y, c0, swapped)
    # Find XOR and AND gates for initial computation
    m1 = find_gate_output(x, y, 'XOR')
    n1 = find_gate_output(x, y, 'AND')

    return [m1, n1] unless c0

    # Process carry logic
    r1 = find_gate_output(c0, m1, 'AND')
    if !r1
      n1, m1 = m1, n1
      swapped.concat([m1, n1])
      r1 = find_gate_output(c0, m1, 'AND')
    end

    z1 = find_gate_output(c0, m1, 'XOR')

    # Check for and handle swapped z wires
    if m1&.start_with?('z')
      m1, z1 = z1, m1
      swapped.concat([m1, z1])
    end

    if n1&.start_with?('z')
      n1, z1 = z1, n1
      swapped.concat([n1, z1])
    end

    if r1&.start_with?('z')
      r1, z1 = z1, r1
      swapped.concat([r1, z1])
    end

    c1 = find_gate_output(r1, n1, 'OR')
    [z1, c1]
  end

  private

  def wire_gate(input1:, input2:, type:, output_name:)
    unless @wires.has_key?(output_name)
      output_wire = Wire.new(output_name)
      @wires[output_name] = output_wire
    end
    output = @wires[output_name]

    gate_class = Object.const_get("#{type}Gate")
    add_gate(gate_class.new([input1, input2], output))
  end
end

file = File.read('2024/day-24/day-24-inputs.txt')

start_wire_values, start_gate_values = file.split("\n\n")

wires = {}
start_wire_values.split("\n").each do |wire_value|
  name, value = wire_value.split(': ')
  wire = Wire.new(name, value.to_i)
  wires[name] = wire
end

system = System.new(wires)
system.add_gates(start_gate_values.split("\n"))

puts "Binary output: #{system.output}"
puts "Decimal output: #{system.to_d}"

# Part 2
puts "Swapped wires: #{system.find_swapped_wires}"