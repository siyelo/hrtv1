class HsspSpend < SpendCodeAssignment

  def self.available_codes(activity = nil)
    if activity.class.to_s == "OtherCost"
      []
    else
      HsspStratObj.all + HsspStratProg.all
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

