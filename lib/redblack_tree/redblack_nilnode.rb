require_relative 'redblack_tree'
require_relative 'redblack_node'

class RedBlackTree
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
