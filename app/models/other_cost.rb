class OtherCost < Activity
  before_save :set_district_if_implement_is_in_one_district

  def set_district_if_implement_is_in_one_district
    #TODO
  end

end







# == Schema Information
#
# Table name: activities
#
#  id                                    :integer         not null, primary key
#  name                                  :string(255)
#  created_at                            :datetime
#  updated_at                            :datetime
#  provider_id                           :integer         indexed
#  description                           :text
#  type                                  :string(255)     indexed
#  budget                                :decimal(, )
#  spend_q1                              :decimal(, )
#  spend_q2                              :decimal(, )
#  spend_q3                              :decimal(, )
#  spend_q4                              :decimal(, )
#  start                                 :date
#  end                                   :date
#  spend                                 :decimal(, )
#  text_for_provider                     :text
#  text_for_targets                      :text
#  text_for_beneficiaries                :text
#  spend_q4_prev                         :decimal(, )
#  data_response_id                      :integer         indexed
#  activity_id                           :integer         indexed
#  budget_percentage                     :decimal(, )
#  spend_percentage                      :decimal(, )
#  approved                              :boolean
#  CodingBudget_amount                   :decimal(, )     default(0.0)
#  CodingBudgetCostCategorization_amount :decimal(, )     default(0.0)
#  CodingBudgetDistrict_amount           :decimal(, )     default(0.0)
#  CodingSpend_amount                    :decimal(, )     default(0.0)
#  CodingSpendCostCategorization_amount  :decimal(, )     default(0.0)
#  CodingSpendDistrict_amount            :decimal(, )     default(0.0)
#  budget_q1                             :decimal(, )
#  budget_q2                             :decimal(, )
#  budget_q3                             :decimal(, )
#  budget_q4                             :decimal(, )
#  budget_q4_prev                        :decimal(, )
#  comments_count                        :integer         default(0)
#  sub_activities_count                  :integer         default(0)
#  new_spend_cents                       :integer         default(0), not null
#  new_spend_currency                    :string(255)
#  new_spend_in_usd                      :integer         default(0), not null
#  new_budget_cents                      :integer         default(0), not null
#  new_budget_currency                   :string(255)
#  new_budget_in_usd                     :integer         default(0), not null
#

