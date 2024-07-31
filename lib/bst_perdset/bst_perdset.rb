require_relative 'bst_perdset_node'

# Persitent dynamic set implemented with BST
class PerdSet
  attr_accessor :root, :hist

  def initialize
    @sentinel = NilNode.new
    @root = @sentinel
    @hist = []
  end

  def <<(value)
    singly_insert value
  end

  def insert(*values)
    values.each do |value|
      singly_insert value
    end
    self
  end

  def singly_insert(value)
    node = InternalNode.new value, @sentinel
    @hist << get_insert_state(node)
    @root = @hist.last
    self
  end

  def get_insert_state(node)
    return node if @root.sentinel?

    cursor = @root
    copied_tree = @root.clone
    copied_node = copied_tree

    until cursor.sentinel?
      return @root if node.value == cursor.value

      if node.value < cursor.value
        copied_node.left = cursor.left.clone
        copied_node = copied_node.left unless copied_node.left.sentinel?
        cursor = cursor.left
      else
        copied_node.right = cursor.right.clone
        copied_node = copied_node.right unless copied_node.right.sentinel?
        cursor = cursor.right
      end
    end

    if node.value < copied_node.value
      copied_node.left = node
    else
      copied_node.right = node
    end
    copied_tree
  end

  def print_history
    @hist.each_with_index do |tree, state|
      puts "state ##{state.to_s.rjust(3, '0')}:"
      puts format_tree tree
    end
    nil
  end

  def to_s
    format_tree
  end

  alias inspect to_s

  # Recursively turn tree into string
  def format_tree(node = @root, prefix = '', output = '', is_left: true)
    unless !node.right || node.right.sentinel?
      format_tree(node.right, "#{prefix}#{is_left ? '│   ' : '    '}",
                  output, is_left: false)
    end

    entry = node.value
    output << "#{prefix}#{is_left ? '└── ' : '┌── '}#{entry}\n"

    unless !node.left || node.left.sentinel?
      format_tree(node.left, "#{prefix}#{is_left ? '    ' : '│   '}",
                  output, is_left: true)
    end

    output
  end
end
