class ImplementerSplit < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  include NumberHelper
  include AutocreateHelper
  include Activity::Classification

  belongs_to :activity, :counter_cache => :sub_activities_count
  belongs_to :organization

  attr_accessible :activity_id, :organization_id, :budget, :spend,
    :provider_mask, :organization,
    :updated_at #TODO: remove updated_at

  ### Validations
  validates_presence_of :provider_mask
  # this seems to be bypassed on activity update if you pass two of the same providers
  validates_uniqueness_of :organization_id, :scope => :activity_id,
    :message => "must be unique", :unless => Proc.new { |m| m.new_record? }
  validates_numericality_of :spend, :if => Proc.new {|is|is.spend.present?}
  validates_numericality_of :budget, :if => Proc.new {|is| is.budget.present?}
  validates_presence_of :spend, :if => lambda {|is| (!((is.budget || 0) > 0)) &&
                                                    (!((is.spend || 0) > 0))},
    :message => " and/or Budget must be present"

  delegate :name, :to => :organization, :prefix => true, :allow_nil => true # gives you implementer_name

  ### Callbacks
  before_validation :strip_mask_fields

  ### Instance methods

  def provider_mask
    @provider_mask || organization_id
  end

  def provider_mask=(the_provider_mask)
    self.organization_id_will_change! # trigger saving of this model
    self.organization_id = self.assign_or_create_organization(the_provider_mask)
    @provider_mask   = self.organization_id
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

  def locations
    code_assignments.with_types(['CodingBudgetDistrict', 'CodingSpendDistrict']).
      find(:all, :include => :code).map{|ca| ca.code }.uniq
  end

  private
    # remove any leading/trailing spaces from the percentage/amount input
    def strip_mask_fields
      provider_mask = provider_mask.strip if provider_mask && !is_number?(provider_mask)
    end

    # if the provider is a clinic or hospital it has only one location
    # so put all the money towards that location
    def adjusted_district_assignments(klass, sub_activity_amount, activity_amount)
      sub_activity_amount ||= 0
      activity_amount ||= 0
      if organization && organization.location && sub_activity_amount > 0
        [fake_ca(klass, organization.location, sub_activity_amount)]
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
end
