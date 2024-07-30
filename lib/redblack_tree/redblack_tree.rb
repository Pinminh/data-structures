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

  def delete_node(target_node)
    replaced_node = target_node
    replaced_color = target_node.color
    replacing_node = nil

    if target_node.left.sentinel?
      replacing_node = target_node.right
      transplant_to target_node, target_node.right
    elsif target_node.right.sentinel?
      replacing_node = target_node.left
      transplant_to target_node, target_node.left
    else
      replaced_node = minimum target_node.right
      replaced_color = replaced_node.color
      replacing_node = replaced_node.right

      unless target_node.right.sentinel?
        transplant_to replaced_node, replacing_node
        replaced_node.right = target_node.right
        target_node.right.parent = replaced_node
      end
      transplant_to target_node, replaced_node
      replaced_node.left = target_node.left
      target_node.left.parent = replaced_node
      replaced_node.color = target_node.color
    end

    # When the original color of replaced node is black,
    # several red-black properties have been violated
    fix_deletion replacing_node if Node.black? replaced_color
    self
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

  # Restore red-black properties after deletion
  # deepblack_node is a pointer to node that has additional black color.
  # The additional black color is not a stored attribute, it is only identified
  # by the act of being pointed to by deepblack_node
  def fix_deletion(deepblack_node)
    until deepblack_node == @root || deepblack_node.red?
      # When replacing node is a left child
      if deepblack_node.left_child?
        sibling = deepblack_node.parent.right
        # Case 1: if sibling of deepblack_node is red,
        # turn this situation into case 2 (fall through) where sibling is black
        if sibling.red?
          sibling.parent.redden
          sibling.blacken
          rotate_left sibling.parent
          sibling = deepblack_node.parent.right
        end
        # Case 2: if the sibling has two black children,
        # transfer additional black color upwards, which interate the next loop
        if sibling.left.black? && sibling.right.black?
          sibling.redden
          deepblack_node = deepblack_node.parent
        # Case 3: if sibling's right child is black,
        # turn this situation into case 4 (fall through),
        # in which the sibling's right child is red instead
        else
          if sibling.right.black?
            sibling.redden
            sibling.left.blacken
            rotate_right sibling
            sibling = deepblack_node.parent.right
          end
          # Case 4: sibling's right child is now red,
          # vanish additional black color to restore red-black properties
          sibling.color = sibling.parent.color
          sibling.parent.blacken
          sibling.right.blacken
          rotate_left sibling.parent
          # Terminate the next loop by going straight to root
          deepblack_node = @root
        end
      # When replacing node is a right child,
      # this is the same to 4 cases above, only left right exchanged
      else
        sibling = deepblack_node.parent.left
        if sibling.red?
          sibling.parent.redden
          sibling.blacken
          rotate_right sibling.parent
          sibling = deepblack_node.parent.left
        end
        if sibling.right.black? && sibling.left.black?
          sibling.redden
          deepblack_node = deepblack_node.parent
        else
          if sibling.left.black?
            sibling.redden
            sibling.right.blacken
            rotate_left sibling
            sibling = deepblack_node.parent.left
          end
          sibling.color = sibling.parent.color
          sibling.parent.blacken
          sibling.left.blacken
          rotate_right sibling.parent
          deepblack_node = @root
        end
      end
    end
    deepblack_node.blacken
  end

  # Replace subtree root with another, dest_node can be nil node,
  # and this nil node is also updated with reference to parent
  def transplant_to(dest_node, src_node)
    if dest_node.parent.sentinel?
      @root = src_node
    elsif dest_node.left_child?
      dest_node.parent.left = src_node
    else
      dest_node.parent.right = src_node
    end
    src_node.parent = dest_node.parent
    nil
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
