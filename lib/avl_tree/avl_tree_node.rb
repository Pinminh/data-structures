class AVLTree
  # General node for AVL tree (height attribute included)
  class Node
    attr_accessor :key, :value, :height, :left, :right, :parent

    def initialize(key, value)
      @key = key
      @value = value
      @height = 0

      @left = @right = @parent = nil
    end

    def root?
      @parent.sentinel?
    end

    def no_left?
      @left.sentinel?
    end

    def no_right?
      @right.sentinel?
    end

    def no_parent?
      @parent.sentinel?
    end

    def leaf?
      no_left? && no_right?
    end

    def left_child?
      @parent.left == self
    end

    def right_child?
      @parent.right == self
    end

    def grandparent
      @parent.parent
    end

    def bfactor
      @right.height - @left.height
    end

    def left_heavy?
      bfactor < -1
    end

    def right_heavy?
      bfactor > 1
    end

    def balanced?
      !left_heavy? && !right_heavy?
    end

    def update_height
      @height = 1 + [@left.height, @right.height].max
    end
  end

  # Sentinel node for AVL tree
  class NilNode < Node
    def initialize
      super(nil, nil)
      @height = -1

      @left = @right = @parent = self
    end

    def sentinel?
      true
    end
  end

  # Node that is not sentinel in AVL tree
  class InternalNode < Node
    def initialize(key, value, sentinel)
      super(key, value)
      @height = 0

      @left = @right = @parent = sentinel
    end

    def sentinel?
      false
    end
  end
end
