class SubActivity < Activity
  extend ActiveSupport::Memoizable

  ### Constants
  IMPLEMENTER_HUMANIZED_ATTRIBUTES = {
    :budget => "Implementer Current Budget",
    :spend => "Implementer Past Expenditure",
    :provider_mask => "Implementer"
  }

  ### Associations
  belongs_to :activity
  # implementer is better, more generic. (Service) Provider is too specific.
  belongs_to :implementer, :foreign_key => :provider_id, :class_name => "Organization" #TODO rename actual column

  ### Attributes
  attr_accessible :activity_id, :data_response_id, :provider_id, :budget, :spend, :updated_at,
    :provider, :data_response, :provider_mask

  ### Validations
  validates_presence_of :provider_mask
  # this seems to be bypassed on activity update if you pass two of the same providers
  validates_uniqueness_of :provider_id, :scope => :activity_id,
    :message => "must be unique", :unless => Proc.new { |m| m.new_record? }
  validates_numericality_of :spend, :if => Proc.new {|is|is.spend.present?}
  validates_numericality_of :budget, :if => Proc.new {|is| is.budget.present?}
  validates_presence_of :spend, :message => " and/or Budget must be present",
    :if => lambda {|is| (!((is.budget || 0) > 0)) && (!((is.spend || 0) > 0))}


  ### Callbacks
  before_validation :strip_mask_fields

  ### Delegates
  [:projects, :name, :description, :approved,
   :text_for_beneficiaries, :beneficiaries, :currency].each do |method|
    delegate method, :to => :activity, :allow_nil => true
  end
  delegate :name, :to => :implementer, :prefix => true, :allow_nil => true # gives you implementer_name

  ### Named Scopes
  named_scope :sorted, { :joins => [:provider], :order => ["organizations.name"]}

  ### Class Methods

  def self.human_attribute_name(attr)
    IMPLEMENTER_HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  ### Instance Methods

  def provider_mask
    @provider_mask || provider_id
  end

  def provider_mask=(the_provider_mask)
    self.provider_id_will_change! # trigger saving of this model
    self.provider_id = self.assign_or_create_organization(the_provider_mask)
    @provider_mask   = self.provider_id
  end

  def budget
    read_attribute(:budget)
  end

  def spend
    read_attribute(:spend)
  end

  def budget=(amount)
    if is_number?(amount)
      write_attribute(:budget, amount.to_f.round_with_precision(2))
    else
      write_attribute(:budget, amount)
    end
  end

  def spend=(amount)
    if is_number?(amount)
      write_attribute(:spend, amount.to_f.round_with_precision(2))
    else
      write_attribute(:spend, amount)
    end
  end

  def locations # TODO: deprecate
    if provider && provider.location.present?
      [provider.location] # TODO - return without array
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

    # if the provider is a clinic or hospital it has only one location
    # so put all the money towards that location
    def adjusted_district_assignments(klass, sub_activity_amount, activity_amount)
      sub_activity_amount ||= 0
      activity_amount ||= 0
      if provider && provider.location && sub_activity_amount > 0
        [fake_ca(klass, provider.location, sub_activity_amount)]
      else
        adjusted_assignments(klass, sub_activity_amount, activity_amount)
      end
    end

    def adjusted_assignments(klass, sub_activity_amount, activity_amount)
      sub_activity_amount ||= 0
      activity_amount ||= 0
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

    # remove any leading/trailing spaces from the percentage/amount input
    def strip_mask_fields
      provider_mask = provider_mask.strip if provider_mask && !is_number?(provider_mask)
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

