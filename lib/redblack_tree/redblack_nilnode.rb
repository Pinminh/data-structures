require_relative 'redblack_node'

class RedBlackTree
  # External nodes of red-black tree, act as black leafs
  class NilNode < Node
    def initialize
      super(key: nil, value: nil)
      @left = @right = @parent = self
      blacken
    end

    def sentinel?
      true
    end
  end
end
