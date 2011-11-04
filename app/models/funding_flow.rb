class FundingFlow < ActiveRecord::Base
  include BudgetSpendHelper
  include AutocreateHelper
  default_scope :order => "id ASC"

  HUMANIZED_ATTRIBUTES = {
    :organization_id_from => "The Funding Source 'from' organization",
    :budget => "The Funding Source Planned Disbursements",
    :spend => "The Funding Source Disbursements Received" }

  ### Attributes
  attr_accessible :organization_text, :project_id, :from, :to,
                  :self_provider_flag, :organization_id_from,
                  :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4,
                  :budget, :budget_q4_prev, :budget_q1, :budget_q2, :budget_q3,
                  :budget_q4

  ### Associations
  belongs_to :from, :class_name => "Organization", :foreign_key => "organization_id_from"
  belongs_to :project
  belongs_to :project_from, :class_name => 'Project' # funder's project

  ### Validations
  # also see validations in BudgetSpendHelper
  #validates_presence_of :project_id # See: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2815-nested-models-build-should-directly-assign-the-parent
                                     # and workaround is in project.rb
  validates_numericality_of :spend, :greater_than => 0,
    :if => Proc.new { |ff| ff.spend.present? && (!ff.budget.present? || ff.budget == 0)  }
  validates_numericality_of :budget, :greater_than => 0,
    :if => Proc.new { |ff| ff.budget.present? && (!ff.spend.present? || ff.spend == 0) }
  validates_presence_of :organization_id_from
  # either budget or spend must be present
  validates_presence_of :spend, :if => lambda {|ff| !ff.budget? && !ff.spend?},
    :message => " and/or Planned must be present"

  # if project from id == nil => then the user hasnt linked them
  # if project from id == 0 => then the user can't find Funder project in a list
  # if project from id > 0 => user has selected a Funder project
  #
  validates_numericality_of :project_from_id, :greater_than_or_equal_to => 0,
    :unless => lambda {|fs| fs["project_from_id"].blank?}
  # if we pass "-1" then the user somehow selected "Add an Organization..."
  validates_numericality_of :organization_id_from, :greater_than_or_equal_to => 0
  validates_uniqueness_of :organization_id_from, :scope => :project_id,
    :unless => Proc.new { |m| m.new_record? }

  ### Callbacks
  before_save :update_cached_usd_amounts

  ### Delegates
  delegate :organization, :to => :project  #allowing nil as a workaround for nested object creation via project
  delegate :data_response, :to => :project
  delegate :currency, :to => :project, :allow_nil => true

  ### Association aliases
  alias :response :data_response
  alias :to :organization

  ### Named Scopes
  named_scope :sorted, { :joins => "LEFT OUTER JOIN organizations ON
    organizations.id = funding_flows.organization_id_from",
    :order => "LOWER(organizations.name) ASC"}

  ### Class Methods

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  ### Instance Methods
  def to_s
    "Project: #{project.name}; From: #{from.name}; To: #{to.name}"
  end

  def name
    self.to_s
  end

  def organization_id_from=(id_or_name)
    self.organization_id_from_will_change! # trigger saving of this model
    new_id = self.assign_or_create_organization(id_or_name)
    super(new_id)
  end

  def self_funded?
    from == to
  end

  def donor_funded?
    ["Donor",  "Multilateral", "Bilateral"].include?(from.raw_type)
  end

  def in_flow?
    self.organization == self.to
  end

  def out_flow?
    self.organization == self.from
  end

  def has_organization_and_amounts?
    organization_id_from && (spend || 0) + (budget || 0) > 0
  end
end







# == Schema Information
#
# Table name: funding_flows
#
#  id                   :integer         not null, primary key
#  organization_id_from :integer
#  project_id           :integer         indexed
#  created_at           :datetime
#  updated_at           :datetime
#  budget               :decimal(, )
#  spend_q1             :decimal(, )
#  spend_q2             :decimal(, )
#  spend_q3             :decimal(, )
#  spend_q4             :decimal(, )
#  organization_text    :text
#  self_provider_flag   :integer         default(0), indexed
#  spend                :decimal(, )
#  spend_q4_prev        :decimal(, )
#  budget_q1            :decimal(, )
#  budget_q2            :decimal(, )
#  budget_q3            :decimal(, )
#  budget_q4            :decimal(, )
#  budget_q4_prev       :decimal(, )
#  project_from_id      :integer
#  budget_in_usd        :decimal(, )     default(0.0)
#  spend_in_usd         :decimal(, )     default(0.0)
#

