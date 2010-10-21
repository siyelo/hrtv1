class BudgetCodeAssignment < CodeAssignment

  def self.classified(activity)
    if activity.budget == nil
      true 
    else
      activity.budget == activity.send("#{self}_amount")
    end
  end

end

# == Schema Information
#
# Table name: code_assignments
#
#  id            :integer         primary key
#  activity_id   :integer
#  code_id       :integer
#  code_type     :string(255)
#  amount        :decimal(, )
#  type          :string(255)
#  percentage    :decimal(, )
#  cached_amount :decimal(, )
#

