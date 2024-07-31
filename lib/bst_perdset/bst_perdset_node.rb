class PerdSet
  # General node of persistence dynamic set
  class Node
    attr_accessor :value, :left, :right

    def initialize(value)
      @value = value
      @left = @right = nil
    end

    def no_left?
      @left.instance_of? NilNode
    end

    def no_right?
      @right.instance_of? NilNode
    end

    def leaf?
      no_left? && no_right?
    end
  end

  # Sentinel node of persistent dynamic set
  class NilNode < Node
    def initialize
      super(nil)
      @left = @right = self
    end

    def sentinel?
      true
    end
  end

  # Node that is not sentinel node
  class InternalNode < Node
    def initialize(value, sentinel)
      super(value)
      @left = @right = sentinel
    end

    def sentinel?
      false
    end
  end
end
