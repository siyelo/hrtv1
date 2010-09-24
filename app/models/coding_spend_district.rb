class CodingSpendDistrict < CodeAssignment

  def self.classified(activity)
    activity.spend == activity.send ("#{self}_amount")
  end

  def self.available_codes(activity = nil)
    activity.locations
  end
end
