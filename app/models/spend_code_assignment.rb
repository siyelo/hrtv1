class SpendCodeAssignment < CodeAssignment

  def self.classified(activity)
    if activity.spend == nil
      true 
    else
      activity.spend == activity.send("#{self}_amount")
    end
  end

end
