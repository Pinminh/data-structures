require_relative 'linked_list'

# Custom hashed map with chaining collisions.
# The growing buckets is coded in C fashion, since Ruby's array out-of-bound
# index defeats the purpose of practicing growing buckets.
class HashMap
  INITIAL_SIZE = 16
  LOAD_FACTOR = 0.75

  KEY_INDEX = 0
  VAL_INDEX = 1

  def initialize
    @buckets = Array.new(INITIAL_SIZE)
    @capacity = INITIAL_SIZE
    @length = 0
  end

  attr_reader :capacity, :length

  def set(key, value)
    entry = Array.new(2)
    entry[KEY_INDEX] = key
    entry[VAL_INDEX] = value

    index = hash key
    @buckets[index] = LinkedList.new if @buckets[index].nil?
    list = @buckets[index]

    list_index = list.find_index { |pair| pair[KEY_INDEX] == key }

    if list_index.nil?
      list.append entry
      @length += 1
    else
      list[list_index][VAL_INDEX] = value
    end

    rehash if @length > LOAD_FACTOR * @capacity
    self
  end

  def get(key)
    index = hash key
    list = @buckets[index]

    return nil if list.nil? || list.empty?

    list.each { |k, v| return v if k == key }
    nil
  end

  def has?(key)
    index = hash key
    list = @buckets[index]

    return false if list.nil? || list.empty?

    !!list.find_index { |k, _| k == key }
  end

  def remove(key)
    index = hash key
    list = @buckets[index]

    list_index = list.find_index { |k, _| k == key }
    return nil if list_index.nil?

    list.delete_at(list_index)[VAL_INDEX]
  end

  def clear
    @buckets = Array.new(INITIAL_SIZE)
    @capacity = INITIAL_SIZE
    @length = 0
  end

  def keys
    entries.map { |pair| pair[KEY_INDEX] }
  end

  def values
    entries.map { |pair| pair[VAL_INDEX] }
  end

  def entries
    entries = []
    @buckets.each do |list|
      entries += list.to_a
    end
    entries
  end

  def empty?
    @length <= 0
  end

  def to_s
    return '{}' if empty?

    string = '{ '
    @buckets.each do |list|
      next if list.nil? || list.empty?

      list.each { |key, value| string += "\"#{key}\": #{value}, " }
    end

    "#{string.slice(0..-3)} }"
  end

  private

  def hash(key)
    hashed = 0
    prime = 31 # 92_821

    key.each_char { |c| hashed = (hashed * prime) + c.ord }
    hashed % @capacity
  end

  def rehash
    @capacity *= 2
    old_buckets = @buckets
    @buckets = Array.new @capacity

    old_buckets.each do |list|
      next if list.nil? || list.empty?

      list.each { |key, value| set key, value }
    end
    nil
  end
end
