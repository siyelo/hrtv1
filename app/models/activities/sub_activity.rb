class SubActivity < Activity
  extend ActiveSupport::Memoizable

  ### Constants
  FILE_UPLOAD_COLUMNS = ["Implementer", "Past Expenditure", "Current Budget"]

  ### Associations
  belongs_to :activity, :counter_cache => true

  ### Attributes
  attr_accessible :activity_id, :data_response_id,
                  :spend_mask, :budget_mask

  ### Callbacks
  after_create    :update_counter_cache
  after_destroy   :update_counter_cache
  before_save     :set_budget_amount
  before_save     :set_spend_amount

  ### Validations
  validates_presence_of :provider_mask
  validate :budget_mask_percentage
  validate :spend_mask_percentage
  validate :numericality_of_budget_mask
  validate :numericality_of_spend_mask

  ### Delegates
  [:projects, :name, :description, :start_date, :end_date, :approved,
   :text_for_beneficiaries, :beneficiaries, :text_for_targets, :currency].each do |method|
    delegate method, :to => :activity, :allow_nil => true
  end

  HUMANIZED_ATTRIBUTES = {
    :budget_mask => "Implementer Current Budget",
    :spend_mask => "Implementer Past Expenditure",
    :provider_mask => "Implementer"
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def spend_mask
    @spend_mask || spend
  end

  def spend_mask=(the_spend_mask)
    @spend_mask = the_spend_mask
  end

  def budget_mask
    @budget_mask || budget
  end

  def budget_mask=(the_budget_mask)
    @budget_mask = the_budget_mask
  end

  ### Class Methods


  def self.download_template(activity = nil)
    FasterCSV.generate do |csv|
      header_row = SubActivity::FILE_UPLOAD_COLUMNS
      (100 - header_row.length).times{ header_row << nil}
      header_row << 'Id'
      csv << header_row

      if activity
        activity.sub_activities.each do |sa|
          row = [sa.provider.try(:name), sa.spend, sa.budget]

          (100 - row.length).times{ row << nil}
          row << sa.id
          csv << row
        end
      end
    end
  end

  def self.create_sa(activity, doc)
    all_ok = true
    sub_activities = {}
    counter = 1
    doc.each do |row|
      provider_id = Organization.find_by_name(row['Implementer']).try(:id)
      if provider_id
        sa = activity.sub_activities.find_by_id(row['Id'])
        attributes = {:budget => row['Current Budget'],
                      :spend => row['Past Expenditure'],
                      :provider_id => provider_id,
                      :data_response_id => activity.data_response.id}

        if sa
          sa.update_attributes(attributes)
          attributes = {}
        else
          activity.sub_activities.create(attributes)
          attributes = {}
        end
      else
        attributes = {counter.to_s => {:budget => row['Current Budget'],
                      :spend => row['Past Expenditure'],
                      :provider_name => row['Implementer'],
                      :row_id => counter,
                      :data_response_id => activity.data_response.id}}
        all_ok = false
      end
      sub_activities.merge! attributes
      counter += 1
    end
    return all_ok, sub_activities
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

    def budget_mask_percentage
      if budget_mask.to_s.last == '%'
        budget_percent = budget_mask.to_s.delete('%').to_f
        errors.add(:budget_mask, "must be between 0% - 100%") if budget_percent < 0 || budget_percent > 100
      end
    end

    def spend_mask_percentage
      if spend_mask.to_s.last == '%'
        spend_percent = spend_mask.to_s.delete('%').to_f
        errors.add(:spend_mask, "must be between 0% - 100%") if spend_percent < 0 || spend_percent > 100
      end
    end

    # validate only if it was supplied - the implementer might not have a budget for the
    # coming period
    def numericality_of_budget_mask
      unless budget_mask.blank?
        budget_mask_number = budget_mask.to_s.last == '%' ?
          budget_mask.to_s.delete('%') : budget_mask
        errors.add(:budget_mask, "is not a number") unless is_number?(budget_mask_number)
      end
    end

    # validate only if it was supplied - the implementer might not only have a budget for the
    # coming period (no expenditure)
    def numericality_of_spend_mask
      unless spend_mask.blank?
        spend_mask_number = spend_mask.to_s.last == '%' ?
          spend_mask.to_s.delete('%') : spend_mask
        errors.add(:spend_mask, "is not a number") unless is_number?(spend_mask_number)
      end
    end

    def set_spend_amount
      if spend_mask.to_s.last == '%'
        self.spend = activity.spend.to_f * spend_mask.to_s.delete('%').to_f / 100
      else
        self.spend = spend_mask
      end
    end

    def set_budget_amount
      if budget_mask.to_s.last == '%'
        self.budget = activity.budget.to_f * budget_mask.to_s.delete('%').to_f / 100
      else
        self.budget = budget_mask
      end
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
#  spend_q1                     :decimal(, )
#  spend_q2                     :decimal(, )
#  spend_q3                     :decimal(, )
#  spend_q4                     :decimal(, )
#  start_date                   :date
#  end_date                     :date
#  spend                        :decimal(, )
#  text_for_provider            :text
#  text_for_targets             :text
#  text_for_beneficiaries       :text
#  spend_q4_prev                :decimal(, )
#  data_response_id             :integer         indexed
#  activity_id                  :integer         indexed
#  approved                     :boolean
#  budget_q1                    :decimal(, )
#  budget_q2                    :decimal(, )
#  budget_q3                    :decimal(, )
#  budget_q4                    :decimal(, )
#  budget_q4_prev               :decimal(, )
#  comments_count               :integer         default(0)
#  sub_activities_count         :integer         default(0)
#  spend_in_usd                 :decimal(, )     default(0.0)
#  budget_in_usd                :decimal(, )     default(0.0)
#  project_id                   :integer
#  ServiceLevelBudget_amount    :decimal(, )     default(0.0)
#  ServiceLevelSpend_amount     :decimal(, )     default(0.0)
#  budget2                      :decimal(, )
#  budget3                      :decimal(, )
#  budget4                      :decimal(, )
#  budget5                      :decimal(, )
#  am_approved                  :boolean
#  user_id                      :integer
#  am_approved_date             :date
#  coding_budget_valid          :boolean         default(FALSE)
#  coding_budget_cc_valid       :boolean         default(FALSE)
#  coding_budget_district_valid :boolean         default(FALSE)
#  service_level_budget_valid   :boolean         default(FALSE)
#  coding_spend_valid           :boolean         default(FALSE)
#  coding_spend_cc_valid        :boolean         default(FALSE)
#  service_level_spend_valid    :boolean         default(FALSE)
#  coding_spend_district_valid  :boolean         default(FALSE)
#

