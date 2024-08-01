require_relative 'avl_tree_node'

# AVL tree implementation
class AVLTree
  attr_accessor :root

  def initialize
    @sentinel = NilNode.new
    @root = @sentinel
  end

  def search_node(key)
    cursor = @root
    until cursor.sentinel?
      return cursor if cursor.key == key

      cursor = key < cursor.key ? cursor.left : cursor.right
    end
    nil
  end

  def minimum(node = @root)
    node = node.left until node.no_left?
    node
  end

  def maximum(node = @root)
    node = node.right until node.no_right?
    node
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

    global_rebalance node
    self
  end

  def delete(node)
    if node.no_right?
      affected_node = node.left
      transplant_to node, node.left
      affected_node = node.parent if affected_node.sentinel?
    elsif node.no_left?
      affected_node = node.right
      transplant_to node, node.right
      affected_node = node.parent if affected_node.sentinel?
    else
      affected_node = successor = minimum node.right
      unless successor == node.right
        affected_node = successor.parent
        replacement = successor.right
        transplant_to successor, replacement
        successor.right = node.right
        node.right.parent = successor
      end
      transplant_to node, successor
      successor.left = node.left
      node.left.parent = successor
    end

    global_rebalance affected_node
    self
  end

  # Replace dest_node with src_node (attaching parent)
  def transplant_to(dest_node, src_node)
    if dest_node.parent.sentinel?
      @root = src_node
    elsif dest_node.left_child?
      dest_node.parent.left = src_node
    else
      dest_node.parent.right = src_node
    end
    src_node.parent = dest_node.parent unless src_node.sentinel?
  end

  # Repeatedly restore balance upto the root
  def global_rebalance(node)
    until node.sentinel?
      node.update_height
      node = local_rebalance node unless node.balanced?
      node = node.parent
    end
  end

  # Restore balance at a node locally
  def local_rebalance(node)
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
