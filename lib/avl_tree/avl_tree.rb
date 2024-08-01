require_relative 'avl_tree_node'

# AVL tree implementation
class AVLTree
  attr_accessor :root

  def initialize
    @sentinel = NilNode.new
    @root = @sentinel
  end

  def insert(key, value = key)
    node = InternalNode.new key, value, @sentinel
    cursor = @root
    parent = cursor.parent

    until cursor.sentinel?
      if cursor.key == key
        raise ArgumentError,
              "key #{key} duplicated in AVL tree"
      end

      parent = cursor
      cursor = key < cursor.key ? cursor.left : cursor.right
    end

    if parent.sentinel?
      @root = node
    elsif key < parent.key
      parent.left = node
    else
      parent.right = node
    end
    node.parent = parent

    self
  end

  def to_s
    format_tree
  end

  alias inspect to_s

  # Recursively turn tree into string
  def format_tree(node = @root, prefix = '', output = '', is_left: true)
    unless !node.right || node.right.sentinel?
      format_tree(node.right, "#{prefix}#{is_left ? '│         ' : '          '}",
                  output, is_left: false)
    end

    entry = "#{node.key}(#{node.value})|#{node.height}|"
    output << "#{prefix}#{is_left ? '└──────── ' : '┌──────── '}#{entry}\n"

    unless !node.left || node.left.sentinel?
      format_tree(node.left, "#{prefix}#{is_left ? '          ' : '│         '}",
                  output, is_left: true)
    end

    output
  end
end
