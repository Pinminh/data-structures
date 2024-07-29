class RedBlackTree
  # Red-black tree's definition of node with special nil node value
  class Node
    include Comparable

    BLACK = 0
    RED = 1

    attr_accessor :key, :value, :color, :left, :right, :parent

    def initialize(key: 0, value: nil, color: BlACK, is_sentinel: false)
      @key = is_sentinel ? nil : key
      @value = value
      @color = color

      pointer = is_sentinel ? nil : RedBlackTree::NIL
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
  NIL = Node.new(is_sentinel: true)

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

  # Assume that node has a non-nil right child
  def rotate_left(node)
    rchild = node.right

    node.right = rchild.left
    rchild.left.parent = node unless rchild.left.sentinel?

    if node.parent.sentinel?
      @root = rchild
    elsif node.parent.left == node
      node.parent.left = rchild
    else
      node.parent.right = rchild
    end
    rchild.parent = node.parent

    rchild.left = node
    node.parent = rchild
  end

  # Assume that node has a non-nil left child
  def rotate_right(node)
    lchild = node.left

    node.left = lchild.right
    lchild.right.parent = node unless lchild.right.sentinel?

    if node.parent.sentinel?
      @root = lchild
    elsif node.parent.left == node
      node.parent.left = lchild
    else
      node.parent.right = lchild
    end
    lchild.parent = node.parent

    lchild.right = node
    node.parent = lchild
  end
end
