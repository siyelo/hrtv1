class Array
  def map_to_hash
    map { |e| yield e }.inject({}) { |carry, e| carry.merge! e }
  end
end
