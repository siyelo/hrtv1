class ValueAtRuntime < Object
  def initialize block
    @block = block
  end

  def quoted_id
    @block.call
  end
end

