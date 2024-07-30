require_relative 'redblack_node'
require_relative 'redblack_nilnode'
require_relative 'redblack_internode'

# Red-black tree implementation
class RedBlackTree
  def initialize(array = nil)
    @sentinel = NilNode.new

    if array.nil?
      @root = @sentinel
      return
    end
    unless array.is_a? Array
      raise TypeError,
            "no implicit conversion of #{array.class} into #{Array}"
    end

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

  def insert(key, value = nil)
    node = InternalNode.new(key, value, sentinel: @sentinel)

    cursor = @root
    parent = @sentinel
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

  def delete_node(target)
    replaced_node = target
    replaced_color = target.color
    replacing_node = replaced_node.color

    if target.left.sentinel?
      replacing_node = target.right
      transplant_to target, target.right
    elsif target.right.sentinel?
      replacing_node = target.left
      transplate_to target, target.left
    else
      replaced_node = minimum target.right
      replaced_color = replaced_node.color
      replacing_node = replaced_node.right

      unless target.right.sentinel?
        transplant_to replaced_node, replacing_node
        replaced_node.right = target.right
        target.right.parent = replaced_node
      end
      transplant_to target, replaced_node
      replaced_node.left = target.left
      target.left.parent = replaced_node
      replaced_node.color = target.color
    end
  end

  def search_node(key, node = @root)
    until node.sentinel? || node.key == key
      node = node.left if key < node.key
      node = node.right if key > node.key
    end
    node
  end

  def maximum(node = @root)
    node = node.right until node.right.sentinel?
    node
  end

  def minimum(node = @root)
    node = node.left until node.left.sentinel?
    node
  end

  def successor(node)
    return minimum node.right unless node.right.sentinel?

    parent = node.parent
    until parent.sentinel? || parent.left == node
      node = parent
      parent = node.parent
    end
    parent
  end

  def predecessor(node)
    return maximum node.left unless node.left.sentinel?

    parent = node.parent
    until parent.sentinel? || parent.right == node
      node = parent
      parent = node.parent
    end
    parent
  end

  private

  # Recursively turn tree into string
  def format_tree(node = @root, prefix = '', output = '', is_left: true)
    unless !node.right || node.right.sentinel?
      format_tree(node.right, "#{prefix}#{is_left ? '│   ' : '    '}",
                  output, is_left: false)
    end

    entry = node.black? ? "\e[1m\e[30m" : "\e[1m\e[31m"
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
    while cursor.parent.red?
      # When parent of cursor is a left child
      if cursor.parent.left_child?
        cursor_uncle = cursor.grandparent.right
        # Case 1: if uncle is RED, pass color BLACK down
        if cursor_uncle.red?
          cursor_uncle.color = cursor.parent.blacken
          cursor.grandparent.redden
          cursor = cursor.grandparent
        else
          # Case 2 (falls through to case 3):
          # if cursor is a right child, transform situation into case 3
          if cursor.right_child?
            cursor = cursor.parent
            rotate_left cursor
          end
          # Case 3: cursor is guaranteed to be a left child,
          # distribute RED under BLACK parent (in rotated configuration)
          cursor.parent.blacken
          cursor.grandparent.redden
          rotate_right cursor.grandparent
        end
      # When parent of cursor is a right child,
      # this is symmetrical to 3 cases above,
      # meaning that it is exactly identical, except left right exchanged
      else
        cursor_uncle = cursor.grandparent.left
        if cursor_uncle.red?
          cursor_uncle.color = cursor.parent.blacken
          cursor.grandparent.redden
          cursor = cursor.grandparent
        else
          if cursor.left_child?
            cursor = cursor.parent
            rotate_right cursor
          end
          cursor.parent.blacken
          cursor.grandparent.redden
          rotate_left cursor.grandparent
        end
      end
    end
    # Loop terminated, but root color is not guranteed
    @root.blacken
  end

  # Replace subtree root with another, dest_node can be nil node,
  # and this nil node is also updated with reference to parent
  def transplant_to(dest_node, src_node)
    if dest_node.sentinel?
      @root = src_node
    elsif dest_node.left_child?
      dest_node.parent.left = src_node
    else
      dest_node.parent.right = src_node
    end
    src_node.parent = dest_node.parent
  end

  # Assume that node has a non-nil right child
  def rotate_left(node)
    rchild = node.right

    node.right = rchild.left
    rchild.left.parent = node unless rchild.left.sentinel?

    if node.parent.sentinel?
      @root = rchild
    elsif node.left_child?
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
    elsif node.left_child?
      node.parent.left = lchild
    else
      node.parent.right = lchild
    end
    lchild.parent = node.parent

    lchild.right = node
    node.parent = lchild
  end
end
