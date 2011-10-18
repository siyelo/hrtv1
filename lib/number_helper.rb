module NumberHelper
  def self.is_number?(i)
    true if Float(i) rescue false
  end
end
