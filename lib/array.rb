# gifted from Dmitry Polushkin
# http://refactormycode.com/codes/552-conversion-from-the-2d-array-to-hash
class Array
  def to_h
    hash = {}
    self.each do |entry|
      hash[entry[0]] = entry[1]
    end
    hash
  end
end
