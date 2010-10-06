class HsspSpend < SpendCodeAssignment

  def self.available_codes(activity = nil)
    if activity.class.to_s == "OtherCost"
      []
    else
      HsspStratObj.all + HsspStratProg.all
    end
  end
end
