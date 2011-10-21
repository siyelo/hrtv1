class OtherCost < Activity
  include ResponseStateCallbacks

  ### Constants
  FILE_UPLOAD_COLUMNS = %w[project_name description current_budget past_expenditure]

  ### Delegates
  delegate :currency, :to => :data_response, :allow_nil => true

  ### Callbacks
  # also check lib/response_state_callbacks

  ### Instance Methods

  # Overrides activity currency delegate method
  # some other costs does not have a project and
  # then we use the currency of the data response
  def currency
    project ? project.currency : data_response.currency
  end

  def human_name
    "Other Cost"
  end

  # An OCost can be considered classified if the locations are classified
  def classified?
    coding_budget_district_valid? && coding_spend_district_valid?
  end

  #TODO: remove
  def budget_classified?
    coding_budget_district_valid?
  end

  #TODO: remove
  def spend_classified?
    coding_spend_district_valid?
  end
end





















# == Schema Information
#
# Table name: activities
#
#  id                           :integer         not null, primary key
#  name                         :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  provider_id                  :integer         indexed
#  description                  :text
#  type                         :string(255)     indexed
#  budget                       :decimal(, )
#  spend                        :decimal(, )
#  text_for_provider            :text
#  text_for_beneficiaries       :text
#  data_response_id             :integer         indexed
#  activity_id                  :integer         indexed
#  approved                     :boolean
#  spend_in_usd                 :decimal(, )     default(0.0)
#  budget_in_usd                :decimal(, )     default(0.0)
#  project_id                   :integer
#  ServiceLevelBudget_amount    :decimal(, )     default(0.0)
#  ServiceLevelSpend_amount     :decimal(, )     default(0.0)
#  am_approved                  :boolean
#  user_id                      :integer
#  am_approved_date             :date
#  coding_budget_valid          :boolean         default(FALSE)
#  coding_budget_cc_valid       :boolean         default(FALSE)
#  coding_budget_district_valid :boolean         default(FALSE)
#  coding_spend_valid           :boolean         default(FALSE)
#  coding_spend_cc_valid        :boolean         default(FALSE)
#  coding_spend_district_valid  :boolean         default(FALSE)
#  planned_for_gor_q1           :boolean
#  planned_for_gor_q2           :boolean
#  planned_for_gor_q3           :boolean
#  planned_for_gor_q4           :boolean
#

