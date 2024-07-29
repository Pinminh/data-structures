class RedBlackTree
  # Red-black tree's definition of node with special nil node value
  class Node
    include Comparable

    BLACK = 0
    RED = 1

    attr_accessor :key, :value, :color, :left, :right, :parent

    def initialize(key: 0, value: nil, color: BlACK, is_nil: false)
      @key = is_nil ? nil : key
      @value = value
      @color = color

      pointer = is_nil ? nil : RedBlackTree::NIL
      @left = @right = @parent = pointer
    end

    def grandparent
      parent.parent
    end

    def sentinel?
      equal?(RedBlackTree::NIL)
    end

    def <=>(other)
      @key <=> other.key
    end
  end

  # Universal sentinel (nil) node
  NIL = Node.new(is_nil: true)

  def initialize
    @root = RedBlackTree::NIL
  end

  # Tree printing
  def pretty_print(node: @root, prefix: '', is_left: true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  # Insert node with no account of colors and rotations
  def bst_insert(node)
    cursor = @root
    parent = RedBlackTree::NIL
    until cursor.sentinel?
      parent = cursor
      cursor = node < cursor ? cursor.left : cursor.right
    end

    node.parent = parent
    if parent.sentinel?
      @root = node
    elsif node < parent
      parent.left = node
    else
      parent.right = node
    end

    node.left = node.right = RedBlackTree::NIL
    node.color = Node::RED
  end
end
