class DataResponse < ActiveRecord::Base
  include NumberHelper
  include ResponseStatesHelper
  extend ActiveSupport::Memoizable

  STATES = ['unstarted', 'started', 'submitted', 'rejected', 'accepted']

  state_machine :state, :initial => :unstarted do
    event :start do
      transition [:unstarted] => :started
    end

    event :unstart do
      transition [:started, :submitted, :rejected, :accepted] => :unstarted
    end

    event :restart do
      transition [:started, :submitted, :rejected, :accepted] => :started
    end

    event :submit do
      transition [:started, :rejected] => :submitted
    end

    event :reject do
      transition [:submitted] => :rejected
    end

    event :accept do
      transition [:submitted] => :accepted
    end
  end

  ### Attributes
  attr_accessible :data_request_id

  ### Associations
  belongs_to :organization
  belongs_to :data_request
  has_many :projects, :dependent => :destroy
  has_many :activities
  # until we get rid of sub-activities, we refer to 'real' activities like this
  # normal_activities deprecates self.activities.roots
  has_many :normal_activities, :class_name => "Activity",
           :conditions => [ "activities.type IS NULL"]
  has_many :other_costs, :dependent => :destroy
  has_many :implementer_splits, :class_name => "SubActivity"
  has_many :sub_activities #deprecate
  has_many :users_currently_completing,
           :class_name => "User",
           :foreign_key => :data_response_id_current
  has_many :comments, :as => :commentable, :dependent => :destroy

  ### Validations
  validates_presence_of   :data_request_id, :organization_id
  validates_uniqueness_of :data_request_id, :scope => :organization_id
  validates_inclusion_of  :state, :in => STATES

  ### Named scopes
  named_scope :unfulfilled, :conditions => ["complete = ?", false]
  named_scope :submitted,   :conditions => ["submitted = ?", true]
  named_scope :ordered, :joins => :data_request, :order => 'data_requests.due_date DESC'
  named_scope :latest_first, {:order => "data_request_id DESC" }

  ### Delegates
  delegate :name, :to => :data_request
  delegate :title, :to => :data_request
  delegate :currency, :fiscal_year_start_date, :fiscal_year_end_date,
    :contact_name, :contact_position, :contact_phone_number,
    :contact_main_office_phone_number, :contact_office_location,
    :to => :organization

  FILE_UPLOAD_COLUMNS = %w[project_name project_description activity_name activity_description
                           amount_in_dollars districts functions inputs]

  def self.in_progress
    self.find :all,
              :select => 'data_responses.*,
                          (SELECT COUNT(*) AS activities_count FROM activities
                            WHERE activities.data_response_id = data_responses.id)',
              :include => [:organization, :projects],
              :conditions => ["(submitted = ? OR submitted is NULL) AND
                               (activities_count > 0)", false]
  end

  # TODO: make a named scope if still in use
  def self.empty
    self.find :all,
      :select => 'data_responses.*, organizations.raw_type',
      :joins => "LEFT JOIN activities ON data_responses.id = activities.data_response_id
                 LEFT JOIN projects ON data_responses.id = projects.data_response_id
                 LEFT OUTER JOIN organizations ON organizations.id = data_responses.organization_id",
      :conditions => ["activities.data_response_id IS NULL AND
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
    activities.empty? && projects.empty?
  end

  def status
    state_to_name(state)
  end

  def load_validation_errors
    errors.add_to_base("Projects are not yet entered.") unless projects_entered?
    errors.add_to_base("Activites are not yet entered.") unless projects_have_activities?
    errors.add_to_base("Activity expenditures and/or current budgets are not yet entered.") unless activity_amounts_entered?
    errors.add_to_base("Activites are not yet classified.") unless activities_coded?
    #errors.add_to_base("Other Costs are not yet entered.") unless projects_have_other_costs?
    errors.add_to_base("Other Costs are not yet classified.") if projects_have_other_costs? && !other_costs_coded?
  end

  ### Submission Validations

  def basics_done?
    projects_entered? &&
    projects_have_activities? &&
    activity_amounts_entered? &&
    activities_coded? &&
    (projects_have_other_costs? ? other_costs_coded? : true)
  end

  def basics_done_to_h
    {:projects_entered =>                                  projects_entered?,
    :projects_have_activities =>                           projects_have_activities?,
    :activity_amounts_entered =>                           activity_amounts_entered?,
    :activities_coded =>                                   activities_coded?,
    :other_costs_coded =>   (projects_have_other_costs? ? other_costs_coded? : true)}
  end

  def ready_to_submit?
    basics_done?
  end

  def projects_entered?
    !projects.empty?
  end
  memoize :projects_entered?

  def projects_without_amounts
    select_without_amounts(self.projects)
  end

  def activities_have_budget_or_spend?
    activities.each do |activity|
      return false if !activity.has_budget_or_spend?
    end
    true
  end

  def projects_without_budget
    projects.select{ |p| !p.budget_entered? }
  end

  def check_projects_funding_sources_have_organizations?
    projects.each do |project|
      return false unless project.funding_sources_have_organizations?
    end
    true
  end

  def projects_linked?
    return false unless projects_entered?
    self.projects.each do |project|
      return false unless project.linked?
    end
    true
  end
  memoize :projects_linked?

  def activities_entered?
    !normal_activities.empty?
  end
  memoize :activities_entered?

  def activity_amounts_entered?
    activities_without_amounts.empty?
  end
  memoize :activity_amounts_entered?

  def activities_without_amounts
    select_without_amounts(self.normal_activities)
  end

  def projects_have_activities?
    activities.find(:first,
                    :select => 'COUNT(DISTINCT(activities.project_id)) as total',
                    :conditions => {:type => nil, :project_id => projects}
                   ).total.to_i == projects.length
  end
  memoize :projects_have_activities?

  def other_costs_entered?
    !other_costs.empty?
  end
  memoize :other_costs_entered?

  def projects_have_other_costs?
    other_costs = activities.find(:first,
                    :select => 'COUNT(DISTINCT(activities.project_id)) as total',
                    :conditions => {:type => 'OtherCost', :project_id => projects}
                   ).total.to_i
    other_costs > 0 && other_costs == projects.length
  end
  memoize :projects_have_other_costs?

  def project_and_activities_matching_amounts?(project, amount_method)
    m = amount_method
    p_total = (project.send(m) || 0)
    leeway = one_hundred_dollar_leeway(project.currency)
    a_total = project.direct_activities_total(m) || 0
    o_total = project.other_costs_total(m) || 0
    p_total + leeway >= a_total + o_total && p_total - leeway <= a_total + o_total
  end

  def uncoded_activities
    reject_uncoded(normal_activities)
  end

  def coded_activities
    select_coded(normal_activities)
  end

  def uncoded_other_costs
    reject_uncoded_locations(other_costs)
  end

  def coded_other_costs
    select_coded(other_costs)
  end

  def activities_coded?
    activities_entered? && uncoded_activities.empty?
  end
  memoize :activities_coded?

  def other_costs_coded?
    other_costs_entered? && uncoded_other_costs.empty?
  end
  memoize :other_costs_coded?

  def total_project_spend_in_usd
    projects.inject(0) {|sum,p| p.spend.nil? ? sum : sum + universal_currency_converter(p.spend, p.currency, "USD")}
  end

  def total_project_budget_in_usd
    projects.inject(0) {|sum,p| p.budget.nil? ? sum : sum + universal_currency_converter(p.budget, p.currency, "USD")}
  end

  def budget
    activities.only_simple.inject(0) do |sum, activity|
      sum + (activity.budget || 0) * currency_rate(activity.currency, currency)
    end
  end

  def spend
    activities.only_simple.inject(0) do |sum, activity|
      sum + (activity.spend || 0) * currency_rate(activity.currency, currency)
    end
  end

  def total_activities_and_other_costs_spend_in_usd
    total_activities_and_other_costs_in_usd("spend")
  end

  def total_activities_and_other_costs_budget_in_usd
    total_activities_and_other_costs_in_usd("budget")
  end

  def total_activities_and_other_costs_in_usd(method)
    activities.only_simple.inject(0) do |sum, a|
      unless a.nil? or !a.respond_to?(method) or a.send(method).nil?
        sum + universal_currency_converter(a.send(method), a.currency, :USD)
      else
        sum
      end
    end
  end

  def submittable?
    started? || rejected?
  end

  private
    def reject_uncoded(activities)
      activities.select{ |a| !a.budget_classified? || !a.spend_classified? }
    end

    def reject_uncoded_locations(other_costs)
      other_costs.select{ |a| !a.coding_budget_district_classified? ||
          !a.coding_spend_district_classified? }
    end

    # Find all complete Activities
    def select_coded(activities)
      activities.select{ |a| a.classified? }
    end

    # Find all complete Ocosts
    def select_coded_ocosts(other_costs)
      other_costs.select{ |a| a.classified? }
    end

    def select_failing(collection, validation_method, amount_method)
      collection.select{|e| !self.send(validation_method, e, amount_method)}
    end

    def select_without_amounts(items)
      items.select { |a| !a.spend_entered? && !a.budget_entered? }
    end
end




# == Schema Information
#
# Table name: data_responses
#
#  id                                :integer         not null, primary key
#  data_request_id                   :integer         indexed
#  created_at                        :datetime
#  updated_at                        :datetime
#  organization_id                   :integer         indexed
#  comments_count                    :integer         default(0)
#  activities_count                  :integer         default(0)
#  sub_activities_count              :integer         default(0)
#  activities_without_projects_count :integer         default(0)
#  unclassified_activities_count     :integer         default(0)
#  state                             :string(255)
#

