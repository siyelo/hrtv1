class BudgetCodeAssignment < CodeAssignment

  def self.classified(activity)
    if activity.budget == nil
      true 
    else
      activity.budget == activity.send("#{self}_amount")
    end
  end

end
