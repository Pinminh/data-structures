# Singly linked list with array-like interface
class LinkedList
  # Since variable is a reference for object in Ruby, @next acts like a pointer.
  # There's no need for deallocating them too.
  class Node
    def initialize(value, next_node = nil)
      @value = value
      @next = next_node
    end

    attr_accessor :value, :next

    def no_next?
      @next.nil?
    end
  end
  ##############################################################################
  ## Initialization

  def initialize(*args, &block)
    if args.length > 2
      raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 0..2)"
    elsif args.empty?
      _init_no_args
    elsif args[0].nil?
      raise TypeError, 'no implicit conversion from nil to integer' if args[0].nil?
    elsif args.length == 1 && !args[0].is_a?(Numeric)
      _init_by_array args[0] if args[0].is_a? Array
      _init_by_list args[0] if args[0].is_a? LinkedList
      raise TypeError, "no implicit conversion from #{args[0].class} to Integer"
    elsif args.length == 1 && args[0].is_a?(Numeric)
      args[0] = args[0].to_i
      raise ArgumentError, 'negative linked list size' if args[0].negative?

      block_given? ? _init_by_block(args[0], &block) : _init_by_size(args[0])
    elsif args.length == 2
      raise TypeError, "no implicit conversion from #{args[0].class} to Integer" unless args[0].is_a? Numeric

      args[0] = args[0].to_i
      raise ArgumentError, 'negative linked list size' if args[0].negative?

      _init_by_size args[0], args[1]
    end
  end

  def self.[](*args)
    list = LinkedList.new

    args.each { |value| list.append value }
    list
  end

  private

  def _init_no_args
    @head = @tail = nil
    @size = 0
  end

  def _init_by_array(array)
    _init_no_args
    array.each { |value| append value }
  end

  def _init_by_list(list)
    _init_no_args
    _init_by_array(list.to_a)
  end

  def _init_by_size(size, default = nil)
    _init_no_args
    size.times { append default }
  end

  def _init_by_block(size)
    _init_no_args
    size.times { |index| append(yield index) }
  end

  ##############################################################################
  ## Accessibility
  public

  attr_reader :size

  def head
    return nil if @head.nil?

    @head.value
  end

  def tail
    return nil if @tail.nil?

    @tail.value
  end

  def first(amount = (no_args = true; 1))
    return head if no_args
    raise TypeError, 'no implicit conversion from nil to integer' if amount.nil?

    amount = amount.to_i
    amount = @size if amount > @size
    raise ArgumentError, 'negative linked list size' if amount.negative?

    values = LinkedList.new
    node = @head
    until amount.zero?
      values.append node.value

      node = node.next
      amount -= 1
    end

    values
  end

  def last(amount = (no_args = true; 1))
    return tail if no_args
    raise TypeError, 'no implicit conversion from nil to integer' if amount.nil?

    amount = amount.to_i
    amount = @size if amount > @size
    raise ArgumentError, 'negative linked list size' if amount.negative?

    values = LinkedList.new
    node = _at @size - amount
    until node.nil?
      values.append node.value

      node = node.next
    end

    values
  end

  def at(index)
    raise TypeError, 'no implicit conversion from nil to integer' if index.nil?

    _at(index.to_i)&.value
  end

  private

  def _at(index)
    return nil if empty? || index >= @size || index < -@size

    index %= @size
    node = @head

    until index.zero?
      index -= 1
      node = node.next
    end

    node
  end

  ##############################################################################
  ## Inspecting
  public

  def empty?
    @head.nil? && @tail.nil? && @size.zero?
  end

  ##############################################################################
  ## Conversion
  public

  def to_s
    string = '*'
    return '* >nil' if empty?

    node = @head
    until node.nil?
      string += "#{node.value.inspect} >"
      node = node.next
    end

    "#{string}nil"
  end

  alias inspect to_s

  def to_a
    values = []

    node = @head
    until node.nil?
      values << node.value
      node = node.next
    end

    values
  end

  ##############################################################################
  ## Modification
  public

  def append(value)
    appended_node = Node.new value

    if empty?
      @head = @tail = appended_node
    else
      @tail.next = appended_node
      @tail = appended_node
    end

    @size += 1
    self
  end

  def prepend(value)
    appended_node = Node.new value

    if empty?
      @head = @tail = appended_node
    else
      appended_node.next = @head
      @head = appended_node
    end

    @size += 1
    self
  end

  def insert(index, value)
    min_index = -@size
    max_index = @size - 1

    # negative index is too out-of-bound
    if index < min_index - 1
      raise IndexError, "index #{index} too small for linked list; minimum: #{min_index - 1}"
    # negative index is equivalent to inserting at index 0
    elsif index == min_index - 1 || index.zero?
      prepend value
    # positive index is too out-of-bound
    elsif index > max_index
      append nil until index == @size
      append value
    # index is valid, insert as intended
    elsif index.positive?
      _insert_by_index index, value
    else
      _insert_by_index (index % @size) + 1, value
    end

    self
  end

  def pop
    return nil if empty?

    removed_value = @tail.value

    if @size > 1
      previous_node = _at @size - 2
      previous_node.next = nil
      @tail = previous_node
      @size -= 1
    else
      clear
    end

    removed_value
  end

  def shift
    return nil if empty?

    removed_value = @head.value

    if @size > 1
      @head = @head.next
      @size -= 1
    else
      clear
    end

    removed_value
  end

  def delete_at(index)
    raise ArgumentError, 'no implicit conversion from nil to integer' if index.nil?
    raise ArgumentError, "no implicit conversion from #{index.class} to Integer" unless index.is_a? Numeric

    index = index.to_i
    return nil if index < -@size || index >= @size

    index %= @size
    return shift if index.zero?
    return pop if index == @size - 1

    previous_node = _at index - 1
    removed_value = previous_node.next.value
    previous_node.next = previous_node.next.next
    @size -= 1
    removed_value
  end

  def clear
    @head = @tail = nil
    @size = 0
    self
  end

  private

  # index must be postive, and it can't be head nor tail
  def _insert_by_index(index, value)
    previous_node = _at index - 1
    _insert_by_node previous_node, value
  end

  # previous_node must be in the list, and it can't be tail
  def _insert_by_node(previous_node, value)
    inserted_node = Node.new value

    inserted_node.next = previous_node.next
    previous_node.next = inserted_node

    @size += 1
  end

  ##############################################################################
  ## Searching
  public

  def find_index(value)
    found_index = 0
    node = @head

    until node.nil?
      return found_index if node.value == value

      found_index += 1
      node = node.next
    end

    nil
  end

  alias index find_index

  def include?(value)
    found_index = find_index value

    !!found_index
  end

  def find
    node = @head

    until node.nil?
      return node.value if yield node.value

      node = node.next
    end

    nil
  end
end
