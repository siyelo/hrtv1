class DataResponse < ActiveRecord::Base
  include NumberHelper
  extend ActiveSupport::Memoizable

  ### Attributes
  attr_accessible :data_request_id

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
  has_many :projects, :dependent => :destroy
  has_many :users_currently_completing,
           :class_name => "User",
           :foreign_key => :data_response_id_current
  has_many :comments, :as => :commentable, :dependent => :destroy

  ### Validations
  validates_presence_of :data_request_id, :organization_id
  validates_uniqueness_of :data_request_id, :scope => :organization_id

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
    :spend_quarters_months, :budget_quarters_months, :to => :organization

  FILE_UPLOAD_COLUMNS = %w[project_name project_description activity_name activity_description
                           amount_in_dollars districts functions inputs]

  #Includes
  include NumberHelper

  ### Meta Data for Meta Programming
  ## GN TODO: refactor out getting collections of items failing
  ## some validation method and defining those as "magic nicely named" methods
  ## using metaprogramming
  @@validation_methods = []

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

  # TODO: add this back in (GLN). This handles additional associations nicely...
  # looks like changed one to left outer for some reason
  def self.options_hash_for_empty
    h = {}
    h[:joins] = @@data_associations.collect do |assoc|
      "LEFT JOIN #{assoc} ON data_responses.id = #{assoc}.data_response_id"
    end
    h[:conditions] = @@data_associations.collect do |assoc|
      "#{assoc}.data_response_id IS NULL"
    end.join(" AND ")
    h
  end

  #named_scope :empty, options_hash_for_empty

  # TODO: spec
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

  # TODO: spec
  def status
    return "Complete" if complete
    return "Submitted for Final Review" if submitted_for_final
    return "Submitted" if submitted
    return "Ready to Submit" if ready_to_submit?
    return "Empty / Not Started" if empty?
    return "In Progress"
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
      errors.add_to_base("Projects are not yet entered.") unless projects_entered?
      errors.add_to_base("Project expenditures and/or current budgets are not yet entered.") unless project_amounts_entered?
      errors.add_to_base("Projects are not yet linked.") unless projects_linked?
      errors.add_to_base("Activites are not yet entered.") unless projects_have_activities?
      errors.add_to_base("Activity expenditures and/or current budgets are not yet entered.") unless activity_amounts_entered?
      errors.add_to_base("Activites are not yet coded.") unless activities_coded?
      errors.add_to_base("Other Costs are not yet entered.") unless projects_have_other_costs?
      errors.add_to_base("Other Costs are not yet coded.") unless other_costs_coded?
      errors.add_to_base("Project budget and sum of Funding Source budgets are not equal.") unless projects_and_funding_sources_have_matching_budgets?
      errors.add_to_base("Project expenditures and sum of Funding Source budgets are not equal.") unless projects_and_funding_sources_have_correct_spends?
      errors.add_to_base("Project budget and sum of Activities and Other Costs budgets are not equal.") unless projects_and_activities_have_matching_budgets?
      errors.add_to_base("Project expenditure and sum of Activities and Other Costs expenditures are not equal.") unless projects_and_activities_have_matching_spends?
      return false
    end
  end

  def last_submitted_at
    request.final_review? ? submitted_for_final_at : submitted_at
  end

  ### Submission Validations

  def basics_done?
    projects_entered? &&
    project_amounts_entered? &&
    projects_have_activities? &&
    projects_have_other_costs? &&
    projects_and_funding_sources_have_matching_budgets? &&
    projects_and_funding_sources_have_correct_spends? &&
    activity_amounts_entered? &&
    activities_coded? &&
    other_costs_coded? &&
    projects_and_activities_have_matching_budgets? &&
    projects_and_activities_have_matching_spends?
  end

  def basics_done_to_h
    {:projects_entered =>                                  projects_entered?,
    :project_amounts_entered =>                            project_amounts_entered?,
    :projects_have_activities =>                           projects_have_activities?,
    :projects_have_other_costs =>                          projects_have_other_costs?,
    :projects_and_funding_sources_have_matching_budgets => projects_and_funding_sources_have_matching_budgets?,
    :projects_and_funding_sources_have_correct_spends =>   projects_and_funding_sources_have_correct_spends?,
    :activity_amounts_entered =>                           activity_amounts_entered?,
    :activities_coded =>                                   activities_coded?,
    :other_costs_coded =>                                  other_costs_coded?,
    :projects_and_activities_have_matching_budgets =>       projects_and_activities_have_matching_budgets?,
    :projects_and_activities_have_matching_spends? =>       projects_and_activities_have_matching_spends? }
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
  memoize :projects_entered?

  def project_amounts_entered?
    projects_entered? && projects_without_amounts.empty?
  end
  memoize :project_amounts_entered?

  def projects_without_amounts
    select_without_amounts(self.projects)
  end

  def activities_have_budget_or_spend?
    activities.each do |activity|
      return false if !activity.has_budget_or_spend? && !activity.type == "SubActivity" ## change me later
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
      #return false if project.in_flows.present? && !project.linked?
      return false unless project.linked?
    end
    true
  end
  memoize :projects_linked?

  def activities_entered?
    !normal_activities.empty?
  end
  memoize :activities_entered?

  def activities_have_implementers?
    self.normal_activities.each do |activity|
      return false if activity.provider_id.nil?
    end
    true
  end

  def activity_amounts_entered?
    activities_without_amounts.empty?
  end
  memoize :activity_amounts_entered?

  def activities_without_amounts
    select_without_amounts(self.normal_activities)
  end

  def projects_have_activities?
    # NOTE: old code
    #return false unless activities_entered?
    #self.projects.each do |project|
      #return false unless project.has_activities?
    #end
    #true

    # NOTE: optimization
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
    # NOTE: old code
    #return false unless other_costs_entered?
    #self.projects.each do |project|
      #return false unless project.has_other_costs?
    #end
    #true
    # NOTE: optimization
    activities.find(:first,
                    :select => 'COUNT(DISTINCT(activities.project_id)) as total',
                    :conditions => {:type => 'OtherCost', :project_id => projects}
                   ).total.to_i == projects.length
  end
  memoize :projects_have_other_costs?

  def projects_and_funding_sources_have_matching_budgets?
    projects.each do |project|
      return false unless project.amounts_matches_funders?(:budget)
    end
    true
  end
  memoize :projects_and_funding_sources_have_matching_budgets?

  def projects_and_funding_sources_have_correct_spends?
    projects.each do |project|
      return false unless project.amounts_matches_funders?(:spend)
    end
    true
  end
  memoize :projects_and_funding_sources_have_correct_spends?

  def projects_funding_sources_ok?
    projects_and_funding_sources_have_matching_budgets? &&
    projects_and_funding_sources_have_correct_spends?
  end
  memoize :projects_funding_sources_ok?

  def projects_and_activities_have_matching_budgets?
    projects_and_activities_matching_amounts?(:budget)
  end

  def projects_and_activities_have_matching_spends?
    projects_and_activities_matching_amounts?(:spend)
  end

  def projects_activities_ok?
    projects_and_activities_have_matching_budgets? &&
    projects_and_activities_have_matching_spends?
  end
  memoize :projects_activities_ok?

  def projects_and_activities_matching_amounts?(amount_method)
    projects.each do |project|
      return false if !project_and_activities_matching_amounts?(project, amount_method)
    end
    true
  end

  def project_and_activities_matching_amounts?(project, amount_method)
    m = amount_method
    p_total = (project.send(m) || 0)
    leeway = one_hundred_dollar_leeway(project.currency)
    a_total = project.direct_activities_total(m) || 0
    o_total = project.other_costs_total(m) || 0
    p_total + leeway >= a_total + o_total && p_total - leeway <= a_total + o_total
  end

  def projects_with_activities_not_matching_amounts(amount_method)
    select_failing(projects, :project_and_activities_matching_amounts?, amount_method)
  end

  def uncoded_activities
    reject_uncoded(normal_activities)
  end

  def coded_activities
    select_coded(normal_activities)
  end

  def uncoded_other_costs
    reject_uncoded(other_costs)
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

  def total_activities_and_other_costs_spend_in_usd
    total_activities_and_other_costs_in_usd("spend")
  end

  def total_activities_and_other_costs_budget_in_usd
    total_activities_and_other_costs_in_usd("budget")
  end

  def total_activities_and_other_costs_in_usd(method)
    activities.only_simple.with_a_project.inject(0) do |sum, a|
      unless a.nil? or !a.respond_to?(method) or a.send(method).nil?
        sum + universal_currency_converter(a.send(method), a.currency, :USD)
      else
        sum
      end
    end
  end

  private
    def reject_uncoded(activities)
      activities.select{ |a|
        (request.budget? && !a.budget_classified?) ||
        (request.spend? && !a.spend_classified?)}
    end

    # Find all complete Activities
    def select_coded(activities)
      activities.select{ |a| a.classified? }
    end

    def select_failing(collection, validation_method, amount_method)
      collection.select{|e| !self.send(validation_method, e, amount_method)}
    end

    def select_without_amounts(items)
      items.select do |a|
        (!a.spend_entered? && !a.budget_entered? && request.spend_and_budget?) ||
        (!a.spend_entered? && request.only_spend?) ||
        (!a.budget_entered? && request.only_budget?)
      end
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

