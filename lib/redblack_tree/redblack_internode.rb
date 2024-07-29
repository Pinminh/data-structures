require_relative 'redblack_node'

class RedBlackTree
  # Every node in red-black tree, except sentinel
  class InternalNode < Node
    def initialize(key, value = nil, sentinel:)
      super(key: key, value: value)
      @left = @right = @parent = sentinel
      redden
    end

    def sentinel?
      false
    end
  end
end
