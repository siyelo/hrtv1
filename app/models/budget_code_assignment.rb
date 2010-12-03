class BudgetCodeAssignment < CodeAssignment

  def self.classified(activity)
    if activity.budget == nil
      true 
    else
      activity.budget == activity.send("#{self}_amount")
    end
  end
  
  def activity_amount
    ret = activity.try(:budget)
    ret.nil? ? 0 : ret
  end

end


# == Schema Information
#
# Table name: code_assignments
#
#  id              :integer         not null, primary key
#  activity_id     :integer
#  code_id         :integer         indexed
#  amount          :decimal(, )
#  type            :string(255)
#  percentage      :decimal(, )
#  cached_amount   :decimal(, )     default(0.0)
#  sum_of_children :decimal(, )     default(0.0)
#

