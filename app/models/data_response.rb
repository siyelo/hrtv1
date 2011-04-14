require 'lib/ActAsDataElement'
require 'validators'

class DataResponse < ActiveRecord::Base
  include ActsAsDateChecker
  include CurrencyCacheHelpers
  acts_as_commentable

  @@data_associations = %w[activities funding_flows projects]

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

  # TODO: spec
  named_scope :available_to, lambda { |current_user|
    if current_user.nil?
      {:conditions => {:id => -1}} #return no records
    elsif current_user.admin?
      {}
    else
      {:conditions=>{:organization_id => current_user.organization.id}}
    end
  }
  named_scope :unfulfilled, :conditions => ["complete = ?", false]
  named_scope :submitted,   :conditions => ["submitted = ?", true]

  ### Callbacks

  after_save :update_cached_currency_amounts

  ### Class Methods

  def self.in_progress
    self.find(:all, :include => [:organization, :projects],
      :conditions => ["submitted = ? or submitted is NULL", false]).select{ |dr|
        dr.projects.size > 0 or dr.activities.size > 0}
  end

  # TODO: remove
  def self.remove_security
    with_exclusive_scope {find(:all)}
  end

  # TODO: refactor
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
    drs = self.find(:all, options_hash_for_empty)#, :include => {:organization => :users})
    #GN: commented out optimization, this broke the method, returned too many records
    drs.select do |dr|
      (["Agencies", "Govt Agency", "Donors", "Donor", "NGO", "Implementer", "Implementers", "International NGO"]).include?(dr.organization.raw_type)
    end
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
  def unclassified_activities_count
    activities.only_simple.unclassified.count
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
      self.errors.add_to_base("Projects are not yet entered.") if !projects_entered?
      self.errors.add_to_base("Projects are not yet linked.") if !projects_linked?
      self.errors.add_to_base("Activites are not yet coded.") if !activities_coded?
      self.errors.add_to_base("Other Costs are not yet coded.") if !other_costs_coded?
      return false
    end
  end

  ### Submission Validations

  def ready_to_submit?
    projects_entered? &&
    projects_linked? &&
    activities_coded? &&
    other_costs_coded?
  end

  def projects_entered?
    !self.projects.empty?
  end

  def projects_linked?
    false #TODO
  end

  def activities_entered?
    !self.normal_activities.empty?
  end

  def other_costs_entered?
    !self.other_costs.empty?
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
      uncoded = []
      uncoded << activities.reject{ |a| a.budget_classified? } if self.request.budget?
      uncoded << activities.reject{ |a| a.spend_classified? } if self.request.spend?
      uncoded.flatten
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
#

