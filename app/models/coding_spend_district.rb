class CodingSpendDistrict < SpendCodeAssignment

  def self.classified(activity)
    if available_codes(activity).empty?
      true
    else
      super(activity)
    end
  end

  def self.available_codes(activity = nil)
    activity.locations
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

