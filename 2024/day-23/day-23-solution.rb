#!/usr/bin/env ruby
# frozen_string_literal: true

# Part 1
# Create adjacency map
connections = {}

File.foreach('2024/day-23/day-23-inputs.txt') do |line|
  node1, node2 = line.chomp.split('-')
  connections[node1] = [] unless connections[node1]
  connections[node2] = [] unless connections[node2]
  connections[node1] << node2
  connections[node2] << node1
end

connections.transform_values!(&:to_set)

t_triplets = 0
nodes = connections.keys

nodes.each_with_index do |a, i|
  ((i + 1)...nodes.size).each do |j|
    b = nodes[j]
    next unless connections[a].include?(b)

    ((j + 1)...nodes.size).each do |k|
      c = nodes[k]
      if connections[b].include?(c) && connections[c].include?(a)
        # Increment counter if any computer starts with 't'
        t_triplets += 1 if a.start_with?('t') || b.start_with?('t') || c.start_with?('t')
      end
    end
  end
end

puts "Number of lan parties with 't' computers: #{t_triplets}"

# Part 2
# Find largest set of fully connected computers
def find_lan_party(connections)
  # Bron-Kerbosch algorithm
  def bronk(r, p, x, connections, max_found)
    if p.empty? && x.empty?
      max_found[0] = r if r.size > max_found[0].size
      return
    end

    pivot = (p + x).max_by { |v| connections[v].size }
    candidates = p - connections[pivot].to_set

    candidates.each do |v|
      new_r = r + [v]
      new_p = p.intersection(connections[v].to_set)
      new_x = x.intersection(connections[v].to_set)
      bronk(new_r, new_p, new_x, connections, max_found)
      p.delete(v)
      x.add(v)
    end
  end

  nodes = connections.keys
  p = Set.new(nodes)
  max_found = [[]]
  bronk([], p, Set.new, connections, max_found)
  max_found[0]
end

largest_lan_party = find_lan_party(connections)
puts "Password: #{largest_lan_party.sort.join(',')}"
