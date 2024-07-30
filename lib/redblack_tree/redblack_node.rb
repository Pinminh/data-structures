class RedBlackTree
  # Red-black tree's definition of node with special nil node value
  class Node
    BLACK = 0
    RED = 1

    attr_accessor :key, :value, :color, :left, :right, :parent

    def initialize(key: 0, value: nil, color: RED)
      @key = key
      @value = value
      @color = color
      @left = @right = @parent = nil
    end

    def self.black?(color_value)
      color_value == BLACK
    end

    def self.red?(color_value)
      color_value == RED
    end

    def black?
      @color == BLACK
    end

    def red?
      @color == RED
    end

    def blacken
      @color = BLACK
    end

    def redden
      @color = RED
    end

    def grandparent
      parent.parent
    end

    def left_child?
      @parent.left == self
    end

    def right_child?
      @parent.right == self
    end

    # Use keys as total order on nodes
    include Comparable
    def <=>(other)
      @key <=> other.key
    end
  end
end
