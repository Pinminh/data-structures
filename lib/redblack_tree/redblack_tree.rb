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
