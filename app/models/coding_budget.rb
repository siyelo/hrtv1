class CodingBudget < CodeAssignment

  def self.classified(activity)
    available_codes = available_codes(activity)
    codings_sum(available_codes, activity, activity.budget) == activity.budget
  end

  def self.available_codes(activity = nil)
    Code.valid_activity_codes.roots
  end
end
