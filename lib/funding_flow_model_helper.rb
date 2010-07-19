
#TODO where should this be declared, this isn't right place
class ValueAtRuntime < Object
  def initialize block
    @block = block
  end

  def quoted_id
    @block.call
  end
end

