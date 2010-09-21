# == Schema Information
#
# Table name: activities
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  beneficiary            :string(255)
#  target                 :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  provider_id            :integer
#  other_cost_type_id     :integer
#  description            :text
#  type                   :string(255)
#  budget                 :decimal(, )
#  spend_q1               :decimal(, )
#  spend_q2               :decimal(, )
#  spend_q3               :decimal(, )
#  spend_q4               :decimal(, )
#  start                  :date
#  end                    :date
#  spend                  :decimal(, )
#  text_for_provider      :text
#  text_for_targets       :text
#  text_for_beneficiaries :text
#  spend_q4_prev          :decimal(, )
#  data_response_id       :integer
#  activity_id            :integer
#  budget_percentage      :decimal(, )
#  spend_percentage       :decimal(, )
#

require 'lib/ActAsDataElement'

class Activity < ActiveRecord::Base
  VALID_ROOT_TYPES = %w[Mtef Nha Nasa Nsp]

  acts_as_commentable
  include ActAsDataElement
  configure_act_as_data_element

  # Attributes
  attr_accessible :projects, :locations, :text_for_provider,
                  :provider, :name, :description,  :start, :end,
                  :text_for_beneficiaries, :beneficiaries,
                  :text_for_targets, :spend, :spend_q4_prev,
                  :spend_q1, :spend_q2, :spend_q3, :spend_q4,
                  :budget, :approved

  # Associations
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :indicators
  has_and_belongs_to_many :locations
  belongs_to :provider, :foreign_key => :provider_id, :class_name => "Organization"
  has_and_belongs_to_many :organizations # organizations targeted by this activity / aided
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity
  has_many :sub_activities, :class_name => "SubActivity", :foreign_key => :activity_id
  has_many :code_assignments

  # delegate :providers, :to => :projects
  def valid_providers
    #TODO use delegates_to
    projects.valid_providers
  end

  def organization
    self.data_response.responding_organization
  end

  def districts
    self.projects.collect do |proj|
      proj.locations
    end.flatten.uniq
  end

  def classified
    CodingBudget.classified(self) &&
    CodingBudgetCostCategorization.classified(self) &&
    CodingBudgetDistrict.classified(self) &&
    CodingExpenditure.classified(self) &&
    CodingExpenditureCostCategorization.classified(self) &&
    CodingExpenditureDistrict.classified(self)
  end

  def budget?
    CodingBudget.classified(self)
  end

  def budget_by_district?
    CodingBudgetDistrict.classified(self)
  end

  def budget_by_cost_category?
    CodingBudgetCostCategorization.classified(self)
  end

  def spend?
    CodingExpenditure.classified(self)
  end

  def spend_by_district?
    CodingExpenditureDistrict.classified(self)
  end

  def spend_by_cost_category?
     CodingExpenditureCostCategorization.classified(self)
  end


end
