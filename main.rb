require_relative 'lib/linked_list/linked_list'
require_relative 'lib/hash_map'
require_relative 'lib/redblack_tree/redblack_tree'
require_relative 'lib/avl_tree/avl_tree'

require 'faker'

Faker::Creature::Animal.name

puts "\nLINKED LIST\n"

list = LinkedList.new
list.append 'dog'
list.append 'cat'
list.append 'parrot'
list.append 'hamster'
list.append 'snake'
list.append 'turtle'

puts list

puts "\nHASH MAP\n"

hash = HashMap.new
20.times { hash.set Faker::Creature::Animal.name, Random.rand(100) }
puts hash
puts hash.length
puts hash.keys.inspect
puts hash.values.inspect
puts hash.entries.inspect

puts "\nRED-BLACK TREE\n"

rand_array = Array.new(20) { Random.rand 100 }
rb_tree = RedBlackTree[*rand_array]

puts "tree height: #{rb_tree.height}"
puts rb_tree

puts "\nAVL TREE\n"

avl_tree = AVLTree[*rand_array]
puts avl_tree
