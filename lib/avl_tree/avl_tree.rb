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

    fix_balance node
    self
  end

  # Repeatedly restore balance upto the root
  def fix_balance(node)
    cursor = node.parent
    until cursor.sentinel?
      cursor.update_height
      cursor = rebalance cursor unless cursor.balanced?
      cursor = cursor.parent
    end
  end

  # Restore balance at a node locally
  def rebalance(node)
    subtree = node
    # When it is the left branch causing unbalance
    if node.left_heavy?
      left_node = node.left
      leftmost_node = left_node.left
      middle_node = left_node.right
      # Case 1: middle subtree has higher height,
      # this will be transformed into case 2 (fall through)
      rotate_left left_node if middle_node.height > leftmost_node.height
      # Case 2: leftmost subtree has higher height, rotate to get balanced
      rotate_right node
      subtree = node.parent
    # When it is the right branch causing unbalance,
    # this is symetrical to cases above, just left right exchanged
    elsif node.right_heavy?
      right_node = node.right
      rightmost_node = right_node.right
      middle_node = right_node.left
      rotate_right right_node if middle_node.height > rightmost_node.height
      rotate_left node
      subtree = node.parent
    end
    subtree
  end

  def rotate_left(node)
    right_node = node.right

    node.right = right_node.left
    right_node.left.parent = node unless right_node.no_left?

    if node.root?
      @root = right_node
    elsif node.left_child?
      node.parent.left = right_node
    else
      node.parent.right = right_node
    end
    right_node.parent = node.parent

    right_node.left = node
    node.parent = right_node

    node.update_height
    right_node.update_height
    nil
  end

  def rotate_right(node)
    left_node = node.left

    node.left = left_node.right
    left_node.right.parent = node unless left_node.no_right?

    if node.root?
      @root = left_node
    elsif node.right_child?
      node.parent.right = left_node
    else
      node.parent.left = left_node
    end
    left_node.parent = node.parent

    left_node.right = node
    node.parent = left_node

    node.update_height
    left_node.update_height
    nil
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
