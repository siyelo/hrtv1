class CodingSpendDistrict < SpendCodeAssignment

  def self.classified(activity)
    if available_codes(activity).empty?
      true
    else
      super(activity)
    end
  end

  def self.available_codes(activity = nil)
    activity.locations
  end
end
