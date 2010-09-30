class CodingSpend < SpendCodeAssignment

  def self.available_codes(activity = nil)
    if activity.class.to_s == "OtherCost"
      OtherCostCode.roots
    else
      Code.valid_activity_codes.roots
    end
  end
end
