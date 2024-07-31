class LinkedList
  # Since variable is a reference for object in Ruby, @next acts like a pointer.
  # There's no need for deallocating them too.
  class Node
    def initialize(value, next_node = nil)
      @value = value
      @next = next_node
    end

    attr_accessor :value, :next

    def no_next?
      @next.nil?
    end
  end
end
