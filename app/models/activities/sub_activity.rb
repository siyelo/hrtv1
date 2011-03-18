class SubActivity < Activity
  extend ActiveSupport::Memoizable

  ### Associations
  belongs_to :activity, :counter_cache => true

  ### Attributes
  attr_accessible :activity_id, :spend_percentage, :budget_percentage, :data_response_id

  ### Callbacks
  after_create  :update_counter_cache
  after_destroy :update_counter_cache

  ### Delegates
  [:projects, :name, :description, :start_date, :end_date, :approved,
   :text_for_beneficiaries, :beneficiaries, :text_for_targets].each do |method|
    delegate method, :to => :activity, :allow_nil => true
  end

  def locations
    if provider && provider.locations.present?
      provider.locations
    else
      activity.locations
    end
  end

  def budget
    if read_attribute(:budget)
      read_attribute(:budget)
    elsif budget_percentage && activity.budget
      activity.budget * budget_percentage / 100
    else
      nil
    end
  end

  def spend
    if read_attribute(:spend)
      read_attribute(:spend)
    elsif spend_percentage && activity.spend
      activity.spend * spend_percentage / 100
    else
      nil
    end
  end

  # Creates new code_assignments records for sub_activity on the fly
  def code_assignments
    coding_budget + coding_budget_cost_categorization + budget_district_coding_adjusted +
    coding_spend + coding_spend_cost_categorization + spend_district_coding_adjusted
  end
  memoize :code_assignments

  def coding_budget
    adjusted_assignments(CodingBudget, budget, activity.budget)
  end
  memoize :coding_budget

  def budget_district_coding_adjusted
    adjusted_district_assignments(CodingBudgetDistrict, budget, activity.budget)
  end
  memoize :budget_district_coding_adjusted

  def coding_budget_cost_categorization
    adjusted_assignments(CodingBudgetCostCategorization, budget, activity.budget)
  end
  memoize :coding_budget_cost_categorization

  def coding_spend
    adjusted_assignments(CodingSpend, spend, activity.spend)
  end
  memoize :coding_spend

  def spend_district_coding_adjusted
    adjusted_district_assignments(CodingSpendDistrict, spend, activity.spend)
  end
  memoize :spend_district_coding_adjusted

  def coding_spend_cost_categorization
    adjusted_assignments(CodingSpendCostCategorization, spend, activity.spend)
  end
  memoize :coding_spend_cost_categorization

  private

    def update_counter_cache
      self.data_response.sub_activities_count = data_response.sub_activities.count
      self.data_response.save(false)
    end

    # if the provider is a clinic or hospital it has only one location
    # so put all the money towards that location
    def adjusted_district_assignments(klass, sub_activity_amount, activity_amount)
      sub_activity_amount = 0 if sub_activity_amount.blank?
      activity_amount = 0 if activity_amount.blank?

      if locations.size == 1 && sub_activity_amount > 0
        [fake_ca(klass, locations.first, sub_activity_amount)]
      else
        adjusted_assignments(klass, sub_activity_amount, activity_amount)
      end
    end

    def adjusted_assignments(klass, sub_activity_amount, activity_amount)
      sub_activity_amount = 0 if sub_activity_amount.blank?
      activity_amount = 0 if activity_amount.blank?

      old_assignments = activity.code_assignments.with_type(klass.to_s)
      new_assignments = []

      if sub_activity_amount > 0
        old_assignments.each do |ca|
          cached_amount = sub_activity_amount * (ca.cached_amount || 0) / activity_amount
          new_assignments << fake_ca(klass, ca.code, cached_amount)
        end
      end

      return new_assignments
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
#  start_date                            :date
#  end_date                              :date
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
#  spend_in_usd                          :decimal(, )     default(0.0)
#  budget_in_usd                         :decimal(, )     default(0.0)
#  project_id                            :integer
#  budget2                               :decimal(, )
#  budget3                               :decimal(, )
#

