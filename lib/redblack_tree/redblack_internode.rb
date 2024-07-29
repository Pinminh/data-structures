class RedBlackTree
  class InternalNode < Node
    def initialize(key, value = nil, sentinel:)
      super(key: key, value: value)
      @left = @right = @parent = sentinel
      redden
    end

    def sentinel?
      false
    end
  end
end
