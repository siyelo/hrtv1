class SubActivity < Activity
  extend ActiveSupport::Memoizable
  include NumberHelper

  ### Constants
  FILE_UPLOAD_COLUMNS = ["Implementer", "Past Expenditure", "Current Budget"]

  ### Associations
  belongs_to :activity, :counter_cache => true

  ### Attributes
  attr_accessible :activity_id, :spend_percentage, :budget_percentage, :data_response_id, :provider_type

  ### Callbacks
  after_create  :update_counter_cache
  after_destroy :update_counter_cache

  ### Delegates
  [:projects, :name, :description, :approved,
   :text_for_beneficiaries, :beneficiaries, :text_for_targets, :currency].each do |method|
    delegate method, :to => :activity, :allow_nil => true
  end

  ### Class Methods
  def self.bulk_update(response, sub_acts)
    sub_acts.each_pair do |sa_id, attributes|
      sa = response.activities.find(sa_id) # possible issue with scoping here

      budget = attributes['budget'].to_s.strip
      if budget.last == '%'
        sa.budget_percentage = budget.delete('%').strip
        sa.budget = nil
      else
        sa.budget_percentage = nil
        sa.budget = budget.strip
      end

      spend  = attributes['spend'].to_s.strip
      if spend.last == '%'
        sa.spend_percentage = spend.delete('%').strip
        sa.spend = nil
      else
        sa.spend_percentage = nil
        sa.spend = spend.strip
      end

      sa.save
    end
  end


  ### Instance Methods

  def locations
    if provider && provider.locations.present?
      provider.locations
    else
      activity.locations
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

  def self.download_template(activity = nil)
    FasterCSV.generate do |csv|
      header_row = SubActivity::FILE_UPLOAD_COLUMNS
      (100 - header_row.length).times{ header_row << nil}
      header_row << 'Id'

      csv << header_row

      if activity
        activity.sub_activities.each do |sa|
          row = [sa.provider_name , sa.spend, sa.budget]

          (100 - row.length).times{ row << nil}
          row << sa.id
          csv << row
        end
      end
    end
  end

  def self.create_from_file(activity, doc)
    doc.each do |row|
      attributes = {:budget => row['Budget'],
                    :spend => row['Current Expenditure'],
                    :provider_id => Organization.find_by_name(row['Implementer']).try(:id),
                    :data_response_id => activity.data_response.id}
      sa = activity.sub_activities.find_by_id(row['Id'])
      if sa
        sa.update_attributes(attributes)
      else
        activity.sub_activities.create(attributes)
      end
    end
  end

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
          if activity_amount > 0
            cached_amount = sub_activity_amount * (ca.cached_amount || 0) / activity_amount
          else
            # set cached amount to zero, otherwise it is Infinity
            cached_amount = sub_activity_amount
          end
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
#  text_for_targets             :text
#  text_for_beneficiaries       :text
#  spend_q4_prev                :decimal(, )
#  data_response_id             :integer         indexed
#  activity_id                  :integer         indexed
#  budget_percentage            :decimal(, )
#  spend_percentage             :decimal(, )
#  approved                     :boolean
#  comments_count               :integer         default(0)
#  sub_activities_count         :integer         default(0)
#  spend_in_usd                 :decimal(, )     default(0.0)
#  budget_in_usd                :decimal(, )     default(0.0)
#  project_id                   :integer
#  am_approved                  :boolean
#  user_id                      :integer
#  am_approved_date             :date
#  coding_budget_valid          :boolean         default(FALSE)
#  coding_budget_cc_valid       :boolean         default(FALSE)
#  coding_budget_district_valid :boolean         default(FALSE)
#  coding_spend_valid           :boolean         default(FALSE)
#  coding_spend_cc_valid        :boolean         default(FALSE)
#  coding_spend_district_valid  :boolean         default(FALSE)
#

