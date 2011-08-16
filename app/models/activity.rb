require 'validators'

class Activity < ActiveRecord::Base
  include NumberHelper
  include BudgetSpendHelper
  include GorAmountHelpers
  include Activity::Classification
  include Activity::Validations

  ### Constants
  MAX_NAME_LENGTH = 64
  HUMANIZED_ATTRIBUTES = {
    :sub_activities => "Implementers",
    :budget => "Current Budget",
    :spend => "Past Expenditure" }


  ### Attribute Protection
  attr_accessible :text_for_provider, :text_for_beneficiaries, :project_id,
    :name, :description, :start_date, :end_date,
    :approved, :am_approved, :budget, :budget2, :budget3, :budget4, :budget5, :spend,
    :beneficiary_ids, :provider_id,
    :sub_activities_attributes, :organization_ids, :csv_project_name, 
    :csv_provider, :csv_beneficiaries, :csv_targets, :targets_attributes, 
    :outputs_attributes, :am_approved_date, :user_id, :provider_mask


  ### Associations
  belongs_to :provider, :foreign_key => :provider_id, :class_name => "Organization"
  belongs_to :data_response
  belongs_to :project
  belongs_to :user
  has_and_belongs_to_many :organizations # organizations targeted by this activity / aided
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity
  has_many :sub_activities, :class_name => "SubActivity",
                            :foreign_key => :activity_id,
                            :dependent => :destroy
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


  ### Class-Level Method Invocations
  strip_commas_from_all_numbers


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


  ### Callbacks
  # also see callbacks in BudgetSpendHelper
  before_update :update_all_classified_amount_caches, :unless => :is_sub_activity?
  before_save   :auto_create_project
  after_save    :update_counter_cache
  after_destroy :update_counter_cache


  ### Attribute Accessor
  attr_accessor :csv_project_name, :csv_provider, :csv_beneficiaries, :csv_targets


  ### Nested attributes
  accepts_nested_attributes_for :sub_activities, :allow_destroy => true
  accepts_nested_attributes_for :targets, :allow_destroy => true
  accepts_nested_attributes_for :outputs, :allow_destroy => true


  ### Delegates
  delegate :currency, :to => :project, :allow_nil => true
  delegate :data_request, :to => :data_response
  delegate :organization, :to => :data_response


  ### Validations
  # also see validations in BudgetSpendHelper
  before_validation :strip_input_fields
  validate :approved_activity_cannot_be_changed
  validates_presence_of :name, :unless => :is_sub_activity?
  validates_presence_of :description, :if => :is_activity?
  validates_presence_of :project_id, :if => :is_activity?
  validates_presence_of :data_response_id
  validates_date :start_date, :unless => :is_sub_activity?
  validates_date :end_date, :unless => :is_sub_activity?
  validates_dates_order :start_date, :end_date, :message => "Start date must come before End date.", :unless => :is_sub_activity?
  validates_length_of :name, :within => 3..MAX_NAME_LENGTH, :if => :is_activity?, :allow_blank => true
  validate :dates_within_project_date_range, :if => Proc.new { |model| model.start_date.present? && model.end_date.present? }


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

  def self.download_template(response, activities = [])
    FasterCSV.generate do |csv|
      csv << file_upload_columns_with_id_col(response)

      activities.each do |activity|
        row = []
        row << activity.project.try(:name)
        row << activity.name
        row << activity.description
        row << activity.provider.try(:name)
        row << activity.spend
        row << activity.budget
        row << activity.beneficiaries.map{|l| l.short_display}.join(',')
        row << activity.targets.map{|o| o.description}.join(",")
        row << activity.start_date
        row << activity.end_date
        (100 - row.length).times{ row << nil}
        row << activity.id
        csv << row
      end
    end
  end

  def self.find_or_initialize_from_file(response, doc, project_id)
    activities = []
    col_names = file_upload_columns(response)

    doc.each do |row|
      activity_id = row['Id']
      if activity_id.present?
        # reset the activity id if it is already found in previous rows
        # this can happen when user edits existing activities but copies
        # the whole row (then the activity id is also copied)
        if activities.map(&:id).include?(activity_id.to_i)
          activity = response.activities.new
        else
          activity = response.activities.find(activity_id)
        end
      else
        activity = response.activities.new
      end
      activity.csv_project_name        = row["Project Name"].try(:strip)
      activity.name                    = row["Activity Name"].try(:strip)
      activity.description             = row["Activity Description"].try(:strip)
      activity.csv_provider            = row["Provider"].try(:strip)
      activity.spend                   = row["Spend"].try(:strip)
      activity.budget                  = row["Budget"].try(:strip)
      activity.csv_beneficiaries       = row["Beneficiaries"].try(:strip)
      activity.csv_targets             = row["Targets"].try(:strip)
      activity.start_date              = DateHelper::flexible_date_parse(row["Start Date"].try(:strip))
      activity.end_date                = DateHelper::flexible_date_parse(row["End Date"].try(:strip))

      # associations
      if activity.csv_project_name.present?
        # find project by name
        project = response.projects.find_by_name(activity.csv_project_name)
      else
        # find project by project id if present (when uploading activities for project)
        project = project_id.present? ? Project.find_by_id(project_id) : nil
      end

      activity.project       = project if project
      activity.name          = activity.description[0..MAX_NAME_LENGTH-1] if activity.name.blank? && !activity.description.blank?
      provider               = Organization.find(:first,
                                 :conditions => ["name LIKE ?", "%#{activity.csv_provider}%"])
      activity.provider      = provider if provider
      activity.beneficiaries = activity.csv_beneficiaries.to_s.split(',').
                                 map{|b| Beneficiary.find_by_short_display(b.strip)}.compact
      activity.targets       = activity.csv_targets.to_s.split(';').
                                 map{|o| Target.find_or_create_by_description(o.strip)}.compact

      activity.save

      activities << activity
    end

    activities
  end


  ### Instance Methods

  def to_s
    name
  end

  def provider_mask
    @provider_mask || provider_id
  end

  def provider_mask=(the_provider_mask)
    self.provider_id_will_change! # trigger saving of this model

    if is_number?(the_provider_mask)
      self.provider_id = the_provider_mask
    else
      organization = Organization.find_or_create_by_name(the_provider_mask)
      organization.save(false) # ignore any errors e.g. on currency or contact details
      self.provider_id = organization.id
    end

    @provider_mask   = self.provider_id
  end

  def possible_duplicate?
    self.class.canonical_with_scope.find(:first, :conditions => {:id => id}).nil?
  end

  # convenience
  def implementer
    provider
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

  def locations
    code_assignments.with_types(['CodingBudgetDistrict', 'CodingSpendDistrict']).
      find(:all, :include => :code).map{|ca| ca.code }.uniq
  end

  private

  ### Class methods
    def self.file_upload_columns(response)
      ["Project Name",
       "Activity Name",
       "Activity Description",
       "Provider",
       "Past Expenditure",
       "#{response.quarter_label(:spend, 'q4_prev')} Spend",
       "#{response.quarter_label(:spend, 'q1')} Spend",
       "#{response.quarter_label(:spend, 'q2')} Spend",
       "#{response.quarter_label(:spend, 'q3')} Spend",
       "#{response.quarter_label(:spend, 'q4')} Spend",
       "Current Budget",
        "#{response.quarter_label(:budget, 'q4_prev')} Budget",
        "#{response.quarter_label(:budget, 'q1')} Budget",
        "#{response.quarter_label(:budget, 'q2')} Budget",
        "#{response.quarter_label(:budget, 'q3')} Budget",
        "#{response.quarter_label(:budget, 'q4')} Budget",
       "Beneficiaries",
       "Targets",
       "Start Date",
       "End Date"]
    end

    # adds a 'hidden' id column at the end of the row
    def self.file_upload_columns_with_id_col(response)
      header_row = file_upload_columns(response)
      (100 - header_row.length).times{ header_row << nil}
      header_row << 'Id'
      header_row
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
        dr.unclassified_activities_count = dr.activities.only_simple.unclassified.count if dr.respond_to?(:unclassified_activities_count)
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
      errors.add(:base, "Activity was approved by SysAdmin and cannot be changed") if changed? and approved and changed != ["approved"]
    end

    def dates_within_project_date_range
      if project.present? && project.start_date && project.end_date
        errors.add(:start_date, "must be within the projects start date (#{project.start_date}) and the projects end date (#{project.end_date})") if start_date < project.start_date
        errors.add(:end_date, "must be within the projects start date (#{project.start_date}) and the projects end date (#{project.end_date})") if end_date > project.end_date
      end
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
      self.provider_mask = self.provider_mask.strip if self.provider_mask && !is_number?(self.provider_mask)
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
    if project_id == -1
      project = data_response.projects.find_by_name(name)
      unless project
        project= Project.create(:name => name, 
                                :start_date => start_date,  
                                :end_date   => end_date,  
                                :data_response => data_response)
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
#  start_date                   :date
#  end_date                     :date
#  spend                        :decimal(, )
#  text_for_provider            :text
#  text_for_beneficiaries       :text
#  data_response_id             :integer         indexed
#  activity_id                  :integer         indexed
#  approved                     :boolean
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
#  coding_spend_valid           :boolean         default(FALSE)
#  coding_spend_cc_valid        :boolean         default(FALSE)
#  coding_spend_district_valid  :boolean         default(FALSE)
#

