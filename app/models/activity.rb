require 'validators'

class Activity < ActiveRecord::Base
  include NumberHelper
  include BudgetSpendHelper
  include Activity::Classification
  include Activity::Validations
  include AutocreateHelper

  ### Constants
  MAX_NAME_LENGTH = 64
  HUMANIZED_ATTRIBUTES = {
    :sub_activities => "Implementers",
    :budget => "Current Budget",
    :spend => "Past Expenditure" }
  AUTOCREATE = -1

  ### Class-Level Method Invocations
  strip_commas_from_all_numbers

  ### Attribute Accessor
  attr_accessor :csv_project_name, :csv_provider, :csv_beneficiaries, :csv_targets

  ### Attribute Protection
  attr_accessible :text_for_provider, :text_for_beneficiaries, :project_id,
    :name, :description,
    :approved, :am_approved, :budget, :budget2, :budget3, :budget4, :budget5, :spend,
    :beneficiary_ids, :provider_id, :implementer_splits_attributes,
    :sub_activities_attributes, :organization_ids, :csv_project_name,
    :csv_provider, :csv_beneficiaries, :csv_targets, :targets_attributes,
    :outputs_attributes, :am_approved_date, :user_id, :provider_mask, :data_response_id,
    :planned_for_gor_q1, :planned_for_gor_q2, :planned_for_gor_q3, :planned_for_gor_q4

  ### Associations
  #TODO: provider now only used for sub-activities, so should be removed from activity altogether
  # implementer is better, more generic. (Service) Provider is too specific.
  belongs_to :provider, :foreign_key => :provider_id, :class_name => "Organization" # deprecate plox k thx
  belongs_to :data_response #deprecated
  belongs_to :response, :foreign_key => :data_response_id, :class_name => "DataResponse" #TODO: rename class
  belongs_to :project
  belongs_to :user
  has_and_belongs_to_many :organizations # organizations targeted by this activity / aided
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity
  has_many :implementer_splits, :class_name => "SubActivity", :foreign_key => :activity_id,
    :dependent => :destroy #TODO - use non-sti model
  has_many :implementers, :through => :sub_activities, :source => :provider #TODO - use non-sti model
  # deprecated
  has_many :sub_activities, :class_name => "SubActivity",
                            :foreign_key => :activity_id,
                            :dependent => :destroy
  #deprecated
  has_many :sub_implementers, :through => :sub_activities, :source => :provider
  has_many :codes, :through => :code_assignments
  has_many :purposes, :through => :code_assignments,
    :conditions => ["codes.type in (?)", Code::PURPOSES], :source => :code
  has_many :code_assignments, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :coding_budget, :dependent => :destroy
  has_many :coding_budget_cost_categorization, :dependent => :destroy
  has_many :coding_budget_district, :dependent => :destroy
  has_many :coding_spend, :dependent => :destroy
  has_many :coding_spend_cost_categorization, :dependent => :destroy
  has_many :coding_spend_district, :dependent => :destroy
  has_many :targets, :dependent => :destroy
  has_many :outputs, :dependent => :destroy

  ### Callbacks
  # also see callbacks in BudgetSpendHelper
  before_validation :strip_input_fields, :unless => :is_sub_activity?
  before_save   :auto_create_project, :unless => :is_sub_activity?
  after_save    :update_counter_cache, :unless => :is_sub_activity?
  before_update :update_all_classified_amount_caches, :unless => :is_sub_activity?
  after_destroy :update_counter_cache, :unless => :is_sub_activity?

  ### Nested attributes
  accepts_nested_attributes_for :sub_activities, :allow_destroy => true,
    :reject_if => Proc.new { |attrs| attrs['provider_mask'].blank? }
  accepts_nested_attributes_for :targets, :allow_destroy => true
  accepts_nested_attributes_for :outputs, :allow_destroy => true

  ### Delegates
  delegate :currency, :to => :project, :allow_nil => true
  delegate :data_request, :to => :data_response
  delegate :organization, :to => :data_response

  ### Validations
  # also see validations in BudgetSpendHelper
  validate :approved_activity_cannot_be_changed, :unless => :is_sub_activity?
  validates_presence_of :name, :unless => :is_sub_activity?
  validates_presence_of :description, :if => :is_activity?
  validates_presence_of :project_id, :if => :is_activity?
  validates_presence_of :data_response_id
  validates_length_of :name, :within => 3..MAX_NAME_LENGTH, :if => :is_activity?, :allow_blank => true

  ### Scopes
  named_scope :roots,                { :conditions => "activities.type IS NULL" }
  named_scope :greatest_first,       { :order => "activities.budget DESC" }
  named_scope :with_type,         lambda { |type| {:conditions =>
                                             ["activities.type = ?", type]} }
  named_scope :only_simple,          { :conditions => ["activities.type IS NULL
                                    OR activities.type IN (?)", ["OtherCost"]] }
  named_scope :only_simple_with_request, lambda {|request| {
                :select => 'DISTINCT activities.*',
                :joins => 'INNER JOIN data_responses ON
                           data_responses.id = activities.data_response_id',
                :conditions => ['(activities.type IS NULL
                                 OR activities.type IN (?)) AND
                                 data_responses.data_request_id = ?',
                                 'OtherCost', request.id]}}
  named_scope :with_request, lambda {|request| {
              :select => 'DISTINCT activities.*',
              :joins => 'INNER JOIN data_responses ON
                         data_responses.id = activities.data_response_id',
              :conditions => ['data_responses.data_request_id = ?', request.id]}}
  named_scope :with_a_project,       { :conditions => "project_id IS NOT NULL" }
  named_scope :without_a_project,    { :conditions => "project_id IS NULL" }
  named_scope :with_organization,    { :joins => "INNER JOIN data_responses
                                    ON data_responses.id = activities.data_response_id
                                    INNER JOIN organizations
                                    ON data_responses.organization_id = organizations.id" }
  named_scope :implemented_by_health_centers, { :joins => [:provider],
                                    :conditions => ["organizations.raw_type = ?",
                                                    "Health Center"]}
  named_scope :canonical_with_scope, {
    :select => 'DISTINCT activities.*',
    :joins =>
      "INNER JOIN data_responses
        ON activities.data_response_id = data_responses.id
      LEFT JOIN data_responses provider_dr
        ON provider_dr.organization_id = activities.provider_id
      LEFT JOIN organizations ON provider_dr.organization_id = organizations.id",
    :conditions => ["activities.provider_id = data_responses.organization_id
                    OR (provider_dr.id IS NULL OR organizations.users_count = 0)"]
  }
  named_scope :manager_approved,     { :conditions => ["am_approved = ?", true] }
  named_scope :sorted,               { :order => "activities.name" }
  named_scope :sorted_by_id,               { :order => "activities.id" }

  ### Callbacks
  # also see callbacks in BudgetSpendHelper
  before_update :update_all_classified_amount_caches, :unless => :is_sub_activity?
  before_save   :auto_create_project, :unless => :is_sub_activity?
  after_save    :update_counter_cache, :unless => :is_sub_activity?
  after_destroy :update_counter_cache, :unless => :is_sub_activity?

  ### Attribute Accessor
  attr_accessor :csv_project_name, :csv_provider, :csv_beneficiaries, :csv_targets

  ### Nested attributes
  accepts_nested_attributes_for :sub_activities, :allow_destroy => true, :reject_if => Proc.new { |attrs| attrs['provider_mask'].blank? }
  accepts_nested_attributes_for :implementer_splits, :allow_destroy => true
  accepts_nested_attributes_for :targets, :allow_destroy => true
  accepts_nested_attributes_for :outputs, :allow_destroy => true

  ### Delegates
  delegate :currency, :to => :project, :allow_nil => true
  delegate :data_request, :to => :data_response
  delegate :organization, :to => :data_response


  ### Class Methods
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def self.only_simple_activities(activities)
    activities.select{|s| s.type.nil? or s.type == "OtherCost"}
  end

  def self.canonical
    #note due to a data issue, we are getting some duplicates here, so i added uniq. we should fix data issue tho
    a = Activity.all(:joins =>
      "INNER JOIN data_responses ON activities.data_response_id = data_responses.id
      LEFT JOIN data_responses provider_dr ON provider_dr.organization_id = activities.provider_id
      LEFT JOIN (SELECT organization_id, count(*) as num_users
                   FROM users
                GROUP BY organization_id) org_users_count ON org_users_count.organization_id = provider_dr.organization_id ",
     :conditions => ["activities.provider_id = data_responses.organization_id
                      OR (provider_dr.id IS NULL
                      OR org_users_count.organization_id IS NULL)"])
    a.uniq
  end

  def self.unclassified
    self.find(:all).select {|a| !a.classified?}
  end

  def self.download_template(response)
    FasterCSV.generate do |csv|
      csv << file_upload_columns
      response.projects.sorted.each do |project|
        row = []
        row << project.name
        row << project.description
        if project.activities.empty?
          csv << row
        else
          project.activities.roots.sorted.each_with_index do |activity, index|
            row << "" if index > 0 # dont re-print project details on each line
            row << "" if index > 0
            row << activity.name
            row << activity.description
            if activity.sub_activities.empty?
              csv << row
            else
              activity.sub_activities.sorted.each_with_index do |sub_activity, index|
                row << "" if index > 0 # dont re-print activity details on each line
                row << "" if index > 0
                row << "" if index > 0
                row << "" if index > 0
                row << sub_activity.id
                row << sub_activity.provider.try(:name)
                row << sub_activity.spend
                row << sub_activity.budget
                csv << row
                row = []
              end
            end
          end
        end
      end
    end
  end

  def self.find_or_initialize_from_file(response, doc, project_id)
    activities = []
    sub_activities = []
    col_names = file_upload_columns
    activity_name = project_name = sub_activity_name = ''
    project_description = activity_description = ''
    activity_in_memory = false
    existing_sa = nil

    SubActivity.after_save.reject! {|callback| callback.method.to_s == 'update_activity_cache'}

    doc.each do |row|
      activity_name = row['Activity Name'].blank? ? activity_name : row['Activity Name']
      if row['Activity Description'].blank? && row['Activity Name'].blank?
        activity_description =  activity_description
      else
        activity_description = row['Activity Description']
      end

      project_name        = row['Project Name'] || project_name
      project_description = row['Project Description'] || project_description unless row['Project Name'].blank?
      sub_activity_name   = row['Implementer']
      sub_activity_id     = row['Id']
      csv_provider        = row["Implementer"].try(:strip)

      if csv_provider.nil?
        implementer = response.organization
      else
        implementer = Organization.find(:first,:conditions => ["LOWER(name) LIKE ?", "%#{csv_provider.downcase}%"])
      end

      if sub_activity_id.present?
        # reset the sub_activity id if it is already found in previous rows
        # this can happen when user edits existing sub_activities but copies
        # the whole row (then the activity id is also copied)
        unless response.sub_activities.map(&:id).include?(sub_activity_id.to_i)
          begin
            sub_activity = response.sub_activities.find(sub_activity_id)
          rescue
            sub_activity = nil
          end
        end
      end

      unless sub_activity
        sub_activities.each do |sa|
          if sa.provider.name.downcase == csv_provider.downcase && sa.activity.name == activity_name && sa.activity.project.name == project_name
            sub_activity = sa
            existing_sa = sa
          end
        end
      end

      if sub_activity
        #sub_activity ID is present - any changes to the
        #project/activity name/description will change the existing project/activity

        activity = sub_activity.activity
        project  = activity.project
      else
        #sub_activity ID not present or invalid - considered to be a new row.
        #If the project/activity doesn't exist, a new one is created
        activities.each do |a|
          if a.name == activity_name && a.project.name == project_name
            activity = a
            project = a.project
            activity_in_memory = true
          end
        end

        project = (response.projects.find_by_name(project_name) || response.projects.new) unless project
        activity = (project.activities.find_by_name(activity_name) || project.activities.new) unless activity

        existing_sa = SubActivity.find(:first, :conditions => {:provider_id => implementer.id, :activity_id => activity.id, :data_response_id => response.id})
        sub_activity = existing_sa || activity.sub_activities.new
      end

      project.data_response       = response
      project.name                = project_name.try(:strip)
      project.description         = project_description.try(:strip)
      if project.new_record?
        project.start_date        = Time.now #DateHelper::flexible_date_parse(activity_start_date.try(:strip))
        project.end_date          = Time.now + 1.year #DateHelper::flexible_date_parse(activity_end_date.try(:strip))
        ff                        = project.funding_flows.new
        ff.organization_id_from   = project.organization.id
        ff.spend                  = 0
        ff.budget                 = 0
        project.funding_flows << ff #killing performance
      end

      unless response.projects.include?(project)
        response.projects << project
      end

      activity.data_response     = response
      activity.project           = project
      activity.name              = activity_name.try(:strip)
      activity.description       = activity_description.try(:strip)

      sub_activity.provider      = implementer
      sub_activity.activity      = activity
      sub_activity.data_response = response

      if existing_sa
        if sub_activity.spend && row["Past Expenditure"]
          sub_activity.spend += row["Past Expenditure"].to_i
        end
        if sub_activity.budget && row["Current Budget"]
          sub_activity.budget += row["Current Budget"].to_i
        end
      else
        sub_activity.spend  = row["Past Expenditure"]
        sub_activity.budget = row["Current Budget"]
      end


      unless sub_activities.include?(sub_activity)
        activity.sub_activities << sub_activity #this does a save & murders performance
      end

      if activity.new_record? && !activity_in_memory
        activity.sub_activities = [sub_activity] #done like this because the initialize method creates a sub activity by default
      end

      unless activities.include?(activity)
        activities << activity
      end

      unless sub_activities.include?(sub_activity) && !existing_sa
        sub_activities << sub_activity
      end
      activity_in_memory = false
    end

    SubActivity.send :after_save, :update_activity_cache #re-enable callback

    activities
  end

  def self.download_header
    FasterCSV.generate do |csv|
      csv << file_upload_columns
    end
  end

  ### Instance Methods

  # to create subactivities for activities
  def initialize(*params)
    super(*params)
    unless is_sub_activity?
      #needed to fully initialize an activity with default (self-)implementer split
      self.sub_activities.build(:provider_id => self.organization.id,
        :data_response_id => self.data_response_id) if self.data_response_id && self.sub_activities.empty?
      cache_budget_spend
    end
  end

  def update_attributes(params)
    # intercept the classifications and process using the bulk classification update API
    #
    # FIXME: the CodingBlah class method saves the activity in the middle of this update... Not good.
    #
    if params[:classifications]
      params[:classifications].each_pair do |association, values|
        begin
          klass = association.camelcase.constantize
        rescue NameError
          return false
        end
        klass.update_classifications(self, values)
      end
      params.delete(:classifications)
      params.delete(:code_assignment_tree) #not sure why this is a param?
    end

    SubActivity.after_save.reject! {|callback| callback.method.to_s == 'update_activity_cache'}
    result = super(params)
    SubActivity.send :after_save, :update_activity_cache #re-enable callback

    if result
    # if sub activities were passed, update Activity amount cache
      unless is_sub_activity?
        cache_budget_spend
        result = self.save # must let caller know if this failed too...
      end
    end
    result
  end

  # This method calculates the totals of the sub-activities budget/spend
  # This is done because an activities budget/spend is the total of their sub_activities budget/spend
  def sub_activities_totals(method)
    sub_activities.map { |sa| sa.send(method) }.compact.sum || 0
  end

  #saves the subactivities totals into the buget/spend fields
  def cache_budget_spend
    unless is_sub_activity? # to be doubly sure!
      [:budget, :spend].each do |method|
        write_attribute(method, sub_activities_totals(method))
      end
    end
  end

  #preventing user from writing
  def budget=(amount)
    raise Hrt::FieldDeprecated
  end

  #preventing user from writing
  def spend=(amount)
    raise Hrt::FieldDeprecated
  end

  def to_s
    name
  end

  def human_name
    "Activity"
  end

  def provider_mask
    @provider_mask || provider_id
  end

  def provider_mask=(the_provider_mask)
    self.provider_id_will_change! # trigger saving of this model
    self.provider_id = self.assign_or_create_organization(the_provider_mask)
    @provider_mask   = self.provider_id
  end

  def possible_duplicate?
    self.class.canonical_with_scope.find(:first, :conditions => {:id => id}).nil?
  end

  def organization_name
    organization.name
  end

  def update_classified_amount_cache(type)
    set_classified_amount_cache(type)
    self.save(false) # save the activity even if it's approved
  end

  # Updates classified amount caches if budget or spend have been changed
  def update_all_classified_amount_caches
    if budget_changed?
      [CodingBudget, CodingBudgetDistrict,
         CodingBudgetCostCategorization].each do |type|
        set_classified_amount_cache(type)
      end
    end
    if spend_changed?
      [CodingSpend, CodingSpendDistrict,
         CodingSpendCostCategorization].each do |type|
        set_classified_amount_cache(type)
      end
    end
  end

  def deep_clone
    clone = self.clone
    # HABTM's
    %w[organizations beneficiaries].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc))
    end
    # has-many's
    %w[code_assignments sub_activities targets].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc).collect { |obj| obj.clone })
    end
    clone
  end

  def classification_amount(classification_type)
    case classification_type.to_s
    when 'CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization'
      budget
    when 'CodingSpend', 'CodingSpendDistrict', 'CodingSpendCostCategorization'
      spend
    else
      raise "Invalid coding_klass #{classification_type}".to_yaml
    end
  end

  def funding_streams
    return [] if project.nil?
    budget_ratio = budget && project.budget ? budget / project.budget : 0
    spend_ratio  = spend && project.spend ? spend / project.spend : 0
    ufs = project.cached_ultimate_funding_sources
    ufs.each do |fs|
      fs[:budget] = fs[:budget] * budget_ratio if fs[:budget]
      fs[:spend]  = fs[:spend] * spend_ratio if fs[:spend]
    end
    ufs
  end

  def actual_spend
    (spend || 0 )
  end

  def actual_budget
    (budget || 0 )
  end

  def sub_activities_each_have_defined_districts?(coding_type)
    !sub_activity_district_code_assignments_if_complete(coding_type).empty?
  end

  def amount_for_provider(provider, field)
    if sub_activities.empty?
      return self.send(field) if self.provider == provider
    else
      sum = 0
      sub_activities.select{|a| a.provider == provider}.each do |a|
        if a.nil?
          puts "had nil in subactivities in proj #{project.id}"
        else
          amt = a.send(field)
          sum += amt unless amt.nil?
        end
      end
      return sum
    end
    0
  end

  # FIXME performance killer ?
  def locations
    code_assignments.with_types(['CodingBudgetDistrict', 'CodingSpendDistrict']).
      find(:all, :include => :code).map{|ca| ca.code }.uniq
  end

  def sub_activities_total(amount_method)
    smart_sum(sub_activities, amount_method)
  end

  private

  ### Class methods
    def self.file_upload_columns
      ["Project Name",
       "Project Description",
       "Activity Name",
       "Activity Description",
       "Id",
       "Implementer",
       "Past Expenditure",
       "Current Budget"]
    end

    ### Instance methods

    # NOTE: respond_to? is used on some fields because
    # some previous data fixes use this method and at that point
    # some counter cache fields didn't existed
    # TODO: remove the respond_to? when data fixes
    # gets removed from the migrations folder
    def update_counter_cache
      if (dr = self.data_response)
        dr.activities_count = dr.activities.only_simple.count
        dr.activities_without_projects_count = dr.activities.roots.without_a_project.count
        if dr.respond_to?(:unclassified_activities_count)
          dr.unclassified_activities_count = dr.activities.only_simple.unclassified.count
        end
        dr.save(false)
      end
    end

    def set_classified_amount_cache(type)
      coding_tree = CodingTree.new(self, type)
      coding_tree.set_cached_amounts!
      self.send(:"#{get_valid_attribute_name(type)}=", coding_tree.valid?)
    end

    def sub_activity_district_code_assignments_if_complete(coding_type)
      case coding_type
      when 'CodingBudgetDistrict'
        cas = sub_activities.collect{|sub_activity| sub_activity.budget_district_coding_adjusted }
      when 'CodingSpendDistrict'
        cas = sub_activities.collect{|sub_activity| sub_activity.spend_district_coding_adjusted }
      end
      return [] if cas.include?([])
      cas.flatten
    end

    def approved_activity_cannot_be_changed
      message = "Activity was approved by SysAdmin and cannot be changed"
      errors.add(:base, message) if changed? and approved and changed != ["approved"]
    end

    def is_simple?
      self.class.eql?(Activity) || self.class.eql?(OtherCost)
    end

    def is_activity?
      self.class.eql?(Activity)
    end

    def is_sub_activity?
      self.class.eql?(SubActivity)
    end

    def strip_input_fields
      self.name = self.name.strip if self.name
      self.description = self.description.strip if self.description
    end

    def get_valid_attribute_name(type)
      case type.to_s
      when 'CodingBudget' then :coding_budget_valid
      when 'CodingBudgetCostCategorization' then :coding_budget_cc_valid
      when 'CodingBudgetDistrict' then :coding_budget_district_valid
      when 'CodingSpend' then :coding_spend_valid
      when 'CodingSpendCostCategorization' then :coding_spend_cc_valid
      when 'CodingSpendDistrict' then :coding_spend_district_valid
      else
        raise "Unknown type #{type}".to_yaml
      end
    end

   def auto_create_project
     if project_id == AUTOCREATE
      project = data_response.projects.find_by_name(name)
      unless project
        self_funder = FundingFlow.new(:from => self.organization,
                        :spend => self.spend, :budget => self.budget)
        project = Project.create(:name => name, :start_date => Time.now,
                                :end_date => Time.now + 1.year, :data_response => data_response,
                                :in_flows => [self_funder])
      end
      self.project = project
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
#

