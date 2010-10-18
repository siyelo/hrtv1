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

class CodingBudget < BudgetCodeAssignment

  def self.available_codes(activity = nil)
    if activity.class.to_s == "OtherCost"
      OtherCostCode.roots
    else
      Code.for_activities.roots
    end
  end
end
