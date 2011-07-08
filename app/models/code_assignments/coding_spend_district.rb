class CodingSpendDistrict < CodeAssignment
end









# == Schema Information
#
# Table name: code_assignments
#
#  id                   :integer         not null, primary key
#  activity_id          :integer         indexed => [code_id, type]
#  code_id              :integer         indexed, indexed => [activity_id, type]
#  amount               :integer(10)
#  type                 :string(255)     indexed => [activity_id, code_id]
#  percentage           :integer(10)
#  cached_amount        :integer(10)     default(0)
#  sum_of_children      :integer(10)     default(0)
#  created_at           :datetime
#  updated_at           :datetime
#  cached_amount_in_usd :integer(10)     default(0)
#

