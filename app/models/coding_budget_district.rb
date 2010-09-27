class CodingBudgetDistrict < CodeAssignment

  def self.classified(activity)
    if available_codes(activity).empty?
      true
    else
      activity.budget == activity.send("#{self}_amount")
    end
  end

  def self.available_codes(activity = nil)
    activity.locations
  end
end
