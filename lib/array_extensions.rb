class Array
  def map_to_hash
    map { |e| yield e }.inject({}) { |carry, e| carry.merge! e }
  end

  # gifted from Dmitry Polushkin
  # http://refactormycode.com/codes/552-conversion-from-the-2d-array-to-hash
  def to_h
    hash = {}
    self.each do |entry|
      hash[entry[0]] = entry[1]
    end
    hash
  end
end
