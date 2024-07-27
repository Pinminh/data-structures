require_relative 'lib/linked_list'
require_relative 'lib/hash_map'
require 'faker'

list = LinkedList.new

list.append 'dog'
list.append 'cat'
list.append 'parrot'
list.append 'hamster'
list.append 'snake'
list.append 'turtle'

puts list
puts

hash = HashMap.new

20.times { hash.set Faker::Creature::Animal.name, Random.rand(100) }

puts hash
puts hash.length
puts hash.has? 'trout'
puts hash.remove('trout').inspect
puts hash.has? 'trout'
puts hash.keys.to_s
puts hash.values.to_s
puts hash.entries.to_s
