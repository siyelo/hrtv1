require 'validators'

class DataResponse < ActiveRecord::Base
  include ActsAsDateChecker
  include CurrencyCacheHelpers
  acts_as_commentable

  ### Attributes

  attr_accessible :fiscal_year_end_date, :fiscal_year_start_date, :currency, :data_request_id,
                  :contact_name, :contact_name, :contact_position, :contact_phone_number,
                  :contact_main_office_phone_number, :contact_office_location

  ### Associations

  belongs_to :organization
  belongs_to :data_request
  has_many :activities, :dependent => :destroy
  # until we get rid of sub-activities, we refer to 'real' activities like this
  # normal_activities deprecates self.activities.roots
  has_many :normal_activities, :class_name => "Activity",
           :conditions => [ "activities.type IS NULL"], :dependent => :destroy
  has_many :other_costs, :dependent => :destroy
  has_many :sub_activities, :dependent => :destroy
  has_many :funding_flows, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  has_many :commodities, :dependent => :destroy
  has_many :users_currently_completing,
           :class_name => "User",
           :foreign_key => :data_response_id_current

  ### Validations

  validates_presence_of :data_request_id
  validates_presence_of :organization_id
  validates_presence_of :currency, :contact_name, :contact_position,
                        :contact_office_location, :contact_phone_number,
                        :contact_main_office_phone_number


  validates_numericality_of :contact_phone_number, :contact_main_office_phone_number
  # TODO: spec
  validates_date :fiscal_year_start_date
  validates_date :fiscal_year_end_date
  validates_dates_order :fiscal_year_start_date, :fiscal_year_end_date,
    :message => "Start date must come before End date."

  ### Named scopes
  named_scope :unfulfilled, :conditions => ["complete = ?", false]
  named_scope :submitted,   :conditions => ["submitted = ?", true]

  ### Callbacks
  after_save :update_cached_currency_amounts

  def self.in_progress
    self.find :all,
              :select => 'data_responses.*,
                          (SELECT COUNT(*) AS projects_count FROM projects
                            WHERE projects.data_response_id = data_responses.id)
                          (SELECT COUNT(*) AS activities_count FROM activities
                            WHERE activities.data_response_id = data_responses.id)',
              :include => [:organization, :projects],
              :conditions => ["(submitted = ? OR submitted is NULL) AND
                               (projects_count > 0 OR activities_count > 0)", false]
  end

  # TODO: remove
  def self.remove_security
    with_exclusive_scope {find(:all)}
  end

  # TODO: spec
  def self.empty
    self.find :all,
      :select => 'data_responses.*, organizations.raw_type',
      :joins => "LEFT JOIN activities ON data_responses.id = activities.data_response_id
                 LEFT JOIN funding_flows ON data_responses.id = funding_flows.data_response_id
                 LEFT JOIN projects ON data_responses.id = projects.data_response_id
                 LEFT OUTER JOIN organizations ON organizations.id = data_responses.organization_id",
      :conditions => ["activities.data_response_id IS NULL AND
                      funding_flows.data_response_id IS NULL AND
                      projects.data_response_id IS NULL AND
                      organizations.raw_type IN (?)",
                      ["Agencies", "Govt Agency", "Donors", "Donor",
                       "NGO", "Implementer", "Implementers", "International NGO"]],
      :include => {:organization => :users},
      :from => 'data_responses'
  end

  ### Instance Methods

  def request
    self.data_request
  end

  def name
    data_request.try(:title) # some responses does not have data_requst (bug was on staging)
  end

  # TODO: spec
  def empty?
    activities.empty? && projects.empty? && funding_flows.empty?
  end

  # TODO: spec
  def status
    return "Empty / Not Started" if empty?
    return "Submitted" if submitted
    return "In Progress"
  end

  # TODO: spec
  def total_project_budget
    projects.inject(0) {|sum,p| p.budget.nil? ? sum : sum + p.budget}
  end

  # TODO: spec
  def total_project_spend
    projects.inject(0) {|sum,p| p.spend.nil? ? sum : sum + p.spend}
  end

  # TODO: spec
  def total_project_budget_RWF
    projects.inject(0) {|sum,p| p.budget.nil? ? sum : sum + p.budget_RWF}
  end

  # TODO: spec
  def total_project_spend_RWF
    projects.inject(0) {|sum,p| p.spend.nil? ? sum : sum + p.spend_RWF}
  end

  # TODO: spec
  def total_activity_spend
    total_activity_method("spend")
  end

  # TODO: spec
  def total_activity_budget
    total_activity_method("budget")
  end

  # TODO: spec
  def total_activity_spend_RWF
    total_activity_method("spend_RWF")
  end

  # TODO: spec
  def total_activity_budget_RWF
    total_activity_method("budget_RWF")
  end

  # TODO: spec
  def total_activity_method(method)
    activities.only_simple.inject(0) do |sum, a|
      unless a.nil? or !a.respond_to?(method) or a.send(method).nil?
        sum + a.send(method)
      else
        sum
      end
    end
  end

  # Checks if the response is "valid" and marks as Submitted.
  def submit!
    if ready_to_submit?
      if request.final_review?
        self.submitted_for_final    = true
        self.submitted_for_final_at = Time.now
      else # first time submission, or resubmission for initial review
        self.submitted = true
        self.submitted_at = Time.now
      end
      return self.save
    else
      self.errors.add_to_base("Projects are not yet entered.") unless projects_entered?
      self.errors.add_to_base("Project expenditures are not yet entered.") unless projects_spend_entered?
      self.errors.add_to_base("Project budgets are not yet entered.") unless projects_budget_entered?
      self.errors.add_to_base("Projects are not yet linked.") unless projects_linked?
      self.errors.add_to_base("Activites are not yet coded.") unless activities_coded?
      self.errors.add_to_base("Other Costs are not yet coded.") unless other_costs_coded?

      self.errors.add_to_base("Project budget and sum of Funding Source budgets are not equal.") unless projects_have_correct_budgets_for_funding_sources?
      self.errors.add_to_base("Project expenditures and sum of Funding Source budgets are not equal.") unless projects_have_correct_spends_for_funding_sources?

      return false
    end
  end

  def last_submitted_at
    return submitted_for_final_at if request.final_review?
    return submitted_at
  end

  ### Submission Validations

  def basics_done?
    projects_entered? &&
    projects_spend_entered? &&
    projects_budget_entered? &&
    activities_coded? &&
    other_costs_coded?
  end

  def ready_to_submit?
    if request.final_review?
      basics_done? && projects_linked?
    else
      basics_done?
    end
  end

  def projects_entered?
    !projects.empty?
  end

  # if the request asks for spend, check if the spends were entered
  def projects_spend_entered?
    !request.spend? || projects_without_spend.empty?
  end

  def projects_budget_entered?
    !request.budget? || projects_without_budget.empty?
  end

  def projects_without_spend
    self.projects.select{ |p| !p.spend_entered? }
  end

  def projects_without_budget
    self.projects.select{ |p| !p.budget_entered? }
  end

  def projects_linked?
    return false unless projects_entered?
    self.projects.each do |project|
      return false unless project.linked?
    end
    true
  end

  def activities_entered?
    !self.normal_activities.empty?
  end

  def projects_have_activities?
    return false unless activities_entered?
    self.projects.each do |project|
      return false unless project.has_activities?
    end
    true
  end

  def other_costs_entered?
    !self.other_costs.empty?
  end

  def projects_have_other_costs?
    return false unless other_costs_entered?
    self.projects.each do |project|
      return false unless project.has_other_costs?
    end
    true
  end

  def projects_have_correct_budgets_for_funding_sources?
    projects.each do |project|
      total = project.in_flows.reject{|fs| fs.budget.nil?}.sum(&:budget)
      return false if project.budget != total
    end
    true
  end

  def projects_have_correct_spends_for_funding_sources?
    projects.each do |project|
      total = project.in_flows.reject{|fs| fs.spend.nil?}.sum(&:spend)
      return false if project.spend != total
    end
    true
  end

  def uncoded_activities
    reject_uncoded(self.normal_activities)
  end

  def coded_activities
    select_coded(self.normal_activities)
  end

  def uncoded_other_costs
    reject_uncoded(self.other_costs)
  end

  def coded_other_costs
    select_coded(self.other_costs)
  end

  def activities_coded?
    activities_entered? && uncoded_activities.empty?
  end

  def other_costs_coded?
    other_costs_entered? && uncoded_other_costs.empty?
  end

  private
    # Find all incomplete Activities, ignoring missing codings if the
    # Request doesnt ask for that info.
    def reject_uncoded(activities)
      activities.select{ |a|
        (!a.budget_classified? && self.request.budget?) ||
        (!a.spend_classified?  && self.request.spend?) }
    end

    # Find all complete Activities
    def select_coded(activities)
      activities.select{ |a| a.classified? }
    end
end


# == Schema Information
#
# Table name: data_responses
#
#  id                                :integer         not null, primary key
#  data_request_id                   :integer         indexed
#  complete                          :boolean         default(FALSE)
#  created_at                        :datetime
#  updated_at                        :datetime
#  organization_id                   :integer         indexed
#  currency                          :string(255)
#  fiscal_year_start_date            :date
#  fiscal_year_end_date              :date
#  contact_name                      :string(255)
#  contact_position                  :string(255)
#  contact_phone_number              :string(255)
#  contact_main_office_phone_number  :string(255)
#  contact_office_location           :string(255)
#  submitted                         :boolean
#  submitted_at                      :datetime
#  projects_count                    :integer         default(0)
#  comments_count                    :integer         default(0)
#  activities_count                  :integer         default(0)
#  sub_activities_count              :integer         default(0)
#  activities_without_projects_count :integer         default(0)
#  submitted_for_final_at            :datetime
#  submitted_for_final               :boolean
#  unclassified_activities_count     :integer         default(0)
#

