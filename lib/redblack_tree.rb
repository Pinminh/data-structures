# Red-black tree implementation
class RedBlackTree
  # Red-black tree's definition of node with special nil node value
  class Node
    include Comparable

    BLACK = 0
    RED = 1

    attr_accessor :key, :value, :color, :left, :right, :parent

    def initialize(key = 0, value = nil, color = RED, is_sentinel: false)
      @key = is_sentinel ? nil : key
      @value = value
      @color = is_sentinel ? BLACK : color

      nil_pointer = is_sentinel ? nil : RedBlackTree::NIL
      @left = @right = @parent = nil_pointer
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

  def initialize(array = nil)
    if array.nil?
      @root = RedBlackTree::NIL
      return
    end

    raise TypeError, "no implicit conversion of #{array.class} into #{Array}" unless array.is_a? Array

    tree = RedBlackTree[*array]
    @root = tree.instance_variable_get :@root
  end

  # Create tree with an array, using index as keys
  def self.[](*args)
    tree = RedBlackTree.new
    args.each_with_index { |val, idx| tree.insert(idx, val) }
    tree
  end

  def to_s
    format_tree
  end

  alias inspect to_s

  def insert(key, value)
    node = Node.new(key, value)

    cursor = @root
    parent = RedBlackTree::NIL
    until cursor.sentinel?
      print "#{cursor} \n"
      parent = cursor
      cursor = node < cursor ? cursor.left : cursor.right
      raise ArgumentError, "key #{key} duplicated in tree" if node == cursor
    end

    node.parent = parent
    if parent.sentinel?
      @root = node
    elsif node < parent
      parent.left = node
    else
      parent.right = node
    end

    fix_insertion node
    self
  end

  private

  # Recursively turn tree into string
  def format_tree(node = @root, prefix = '', output = '', is_left: true)
    unless !node.right || node.right.sentinel?
      format_tree(node.right, "#{prefix}#{is_left ? '│   ' : '    '}",
                  output, is_left: false)
    end

    entry = node.color == Node::BLACK ? "\e[1m\e[30m" : "\e[1m\e[31m"
    entry << "#{node.key}\e[0m" << "(#{node.value})"
    output << "#{prefix}#{is_left ? '└── ' : '┌── '}#{entry}\n"

    unless !node.left || node.left.sentinel?
      format_tree(node.left, "#{prefix}#{is_left ? '    ' : '│   '}",
                  output, is_left: true)
    end

    output
  end

  # Restore red-black properties after insertion
  def fix_insertion(inserted_node)
    cursor = inserted_node
    while cursor.parent.color == Node::RED
      # When parent of cursor is a left child
      if cursor.parent == cursor.grandparent.left
        cursor_uncle = cursor.grandparent.right
        # Case 1: if uncle is RED, pass color BLACK down
        if cursor_uncle.color == Node::RED
          cursor_uncle.color = cursor.parent.color = Node::BLACK
          cursor.grandparent.color = Node::RED
          cursor = cursor.grandparent
        else
          # Case 2 (falls through to case 3):
          # if cursor is a right child, transform situation into case 3
          if cursor == cursor.parent.right
            cursor = cursor.parent
            rotate_left cursor
          end
          # Case 3: cursor is guaranteed to be a left child,
          # distribute RED under BLACK parent (in rotated configuration)
          cursor.parent.color = Node::BLACK
          cursor.grandparent.color = Node::RED
          rotate_right cursor.grandparent
        end
      # When parent of cursor is a right child,
      # this is symmetrical to 3 cases above,
      # meaning that it is exactly identical, except left right exchanged
      else
        cursor_uncle = cursor.grandparent.left
        if cursor_uncle.color == Node::RED
          cursor_uncle.color = cursor.parent.color = Node::BLACK
          cursor.grandparent.color = Node::RED
          cursor = cursor.grandparent
        else
          if cursor == cursor.parent.left
            cursor = cursor.parent
            rotate_right cursor
          end
          cursor.parent.color = Node::BLACK
          cursor.grandparent.color = Node::RED
          rotate_left cursor.grandparent
        end
      end
    end
    # Loop terminated, but root color is not guranteed
    @root.color = Node::BLACK
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
