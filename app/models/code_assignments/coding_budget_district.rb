class CodingBudgetDistrict < CodeAssignment
end











# == Schema Information
#
# Table name: code_assignments
#
#  id                   :integer         not null, primary key
#  activity_id          :integer
#  code_id              :integer         indexed
#  amount               :decimal(, )
#  type                 :string(255)
#  percentage           :decimal(, )
#  cached_amount        :decimal(, )     default(0.0)
#  sum_of_children      :decimal(, )     default(0.0)
#  created_at           :datetime
#  updated_at           :datetime
#  cached_amount_in_usd :decimal(, )     default(0.0)
#

