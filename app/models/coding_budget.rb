class CodingBudget < CodeAssignment

  def self.classified(activity)
    activity.budget == activity.send ("#{self}_amount")
  end

  def self.available_codes(activity = nil)
    Code.valid_activity_codes.roots
  end
end
