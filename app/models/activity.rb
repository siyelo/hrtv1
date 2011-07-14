require 'lib/BudgetSpendHelpers'
require 'validators'

class Activity < ActiveRecord::Base
  include NumberHelper

  ### Constants
  STRAT_PROG_TO_CODES_FOR_TOTALING = {
    "Quality Assurance" => ["6","7","8","9","11"],
    "Commodities, Supply and Logistics" => ["5"],
    "Infrastructure and Equipment" => ["4"],
    "Health Financing" => ["3"],
    "Human Resources for Health" => ["2"],
    "Governance" => ["101","103"],
    "Planning and M&E" => ["102","104","105","106"]
  }

  STRAT_OBJ_TO_CODES_FOR_TOTALING = {
    "Across all 3 objectives" => ["1","201","202","203","204","206","207",
                                  "208","3","4","5","7","11"],
    "b. Prevention and control of diseases" => ['205','9'],
    "c. Treatment of diseases" => ["601","602","603","604","607","608","6011",
                                   "6012","6013","6014","6015","6016"],
    "a. FP/MCH/RH/Nutrition services" => ["605","609","6010", "8"]
  }

  BUDGET_CODING_CLASSES = ['CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization', 'ServiceLevelBudget']

  CLASSIFICATION_MAPPINGS = {
    'CodingBudget' => 'CodingSpend',
    'CodingBudgetDistrict' => 'CodingSpendDistrict',
    'CodingBudgetCostCategorization' => 'CodingSpendCostCategorization',
    'ServiceLevelBudget' => 'ServiceLevelSpend'
  }

  HUMANIZED_ATTRIBUTES = {
    :sub_activities => "Implementers"
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  ### Includes
  include BudgetSpendHelpers
  strip_commas_from_all_numbers

  ### Attributes
  attr_accessible :text_for_provider, :text_for_beneficiaries, :project_id,
    :text_for_targets, :name, :description, :start_date, :end_date,
    :approved, :am_approved, :budget, :budget2, :budget3, :budget4, :budget5, :spend,
    :spend_q1, :spend_q2, :spend_q3, :spend_q4, :spend_q4_prev,
    :budget_q1, :budget_q2, :budget_q3, :budget_q4, :budget_q4_prev,
    :beneficiary_ids, :location_ids, :provider_id,
    :sub_activities_attributes, :organization_ids, :funding_sources_attributes,
    :csv_project_name, :csv_provider, :csv_districts, :csv_beneficiaries,
    :outputs_attributes, :am_approved_date, :user_id, :provider_mask

  attr_accessor :csv_project_name, :csv_provider, :csv_districts, :csv_beneficiaries

  ### Associations
  belongs_to :provider, :foreign_key => :provider_id, :class_name => "Organization"
  belongs_to :data_response
  belongs_to :project
  belongs_to :user
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :organizations # organizations targeted by this activity / aided
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity
  has_many :sub_activities, :class_name => "SubActivity",
                            :foreign_key => :activity_id,
                            :dependent => :destroy
  has_many :sub_implementers, :through => :sub_activities, :source => :provider, :dependent => :destroy
  has_many :funding_sources, :dependent => :destroy
  has_many :codes, :through => :code_assignments
  has_many :code_assignments, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :coding_budget, :dependent => :destroy
  has_many :coding_budget_cost_categorization, :dependent => :destroy
  has_many :coding_budget_district, :dependent => :destroy
  has_many :service_level_budget, :dependent => :destroy
  has_many :coding_spend, :dependent => :destroy
  has_many :coding_spend_cost_categorization, :dependent => :destroy
  has_many :coding_spend_district, :dependent => :destroy
  has_many :service_level_spend, :dependent => :destroy
  has_many :outputs, :dependent => :destroy

  ### Nested attributes
  accepts_nested_attributes_for :sub_activities, :allow_destroy => true
  accepts_nested_attributes_for :funding_sources, :allow_destroy => true,
    :reject_if => lambda {|fs| fs["funding_flow_id"].blank? }
  accepts_nested_attributes_for :outputs, :allow_destroy => true

  ### Delegates
  delegate :currency, :to => :project, :allow_nil => true
  delegate :data_request, :to => :data_response
  delegate :organization, :to => :data_response

  ### Validations
  before_validation :strip_leading_spaces
  validate :approved_activity_cannot_be_changed

  validates_presence_of :name, :if => :is_activity?
  validates_presence_of :description, :if => :is_activity?
  validates_presence_of :project_id, :if => :is_activity?
  validates_presence_of :data_response_id
  validates_numericality_of :spend, :if => Proc.new { |model| !model.spend.blank? }, :unless => Proc.new { |model| model.activity_id }
  validates_numericality_of :budget, :if => Proc.new { |model| !model.budget.blank?}, :unless => Proc.new {|model| model.activity_id }
  validates_date :start_date, :unless => :is_sub_activity?
  validates_date :end_date, :unless => :is_sub_activity?
  validates_dates_order :start_date, :end_date, :message => "Start date must come before End date.", :unless => :is_sub_activity?
  validates_length_of :name, :within => 3..64, :if => :is_activity?, :allow_blank => true
  validate :dates_within_project_date_range, :if => Proc.new { |model| model.start_date.present? && model.end_date.present? }

  #validates_associated :sub_activities

  ### Callbacks
  before_save :update_cached_usd_amounts
  before_update :remove_district_codings
  before_update :update_all_classified_amount_caches, :unless => Proc.new { |model| model.class.to_s == 'SubActivity' }
  after_save  :update_counter_cache
  after_destroy :update_counter_cache
  before_save :set_total_amounts

  ### Named scopes
  # TODO: spec
  named_scope :roots,             {:conditions => "activities.type IS NULL" }
  named_scope :greatest_first,    {:order => "activities.budget DESC" }
  named_scope :with_type,         lambda { |type| {:conditions => ["activities.type = ?", type]} }
  named_scope :only_simple,       { :conditions => ["activities.type IS NULL
                                    OR activities.type IN (?)", ["OtherCost"]] }
  named_scope :with_a_project,    { :conditions => "activities.id IN (SELECT activity_id FROM activities_projects)" }
  named_scope :without_a_project, { :conditions => "project_id IS NULL" }
  named_scope :with_organization, { :joins => "INNER JOIN data_responses ON data_responses.id = activities.data_response_id " +
                                              "INNER JOIN organizations on data_responses.organization_id = organizations.id" }
  named_scope :implemented_by_health_centers, { :joins => [:provider], :conditions => ["organizations.raw_type = ?", "Health Center"]}
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
  named_scope :manager_approved, { :conditions => ["am_approved = ?", true] }
  named_scope :sorted,           {:order => "activities.name" }

  def self.only_simple_activities(activities)
    activities.select{|s| s.type.nil? or s.type == "OtherCost"}
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
      self.provider_id = organization.id if organization.id.present?
    end

    @provider_mask   = self.provider_id
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

  def self.jawp_activities
    Activity.only_simple.find(:all,
      :include => [:locations, :provider, :organizations,
                  :beneficiaries, {:data_response => :organization}])
  end

  def self.download_template(response, activities = [])
    FasterCSV.generate do |csv|
      header_row = file_upload_columns(response)
      (100 - header_row.length).times{ header_row << nil}
      header_row << 'Id'
      csv << header_row

      activities.each do |activity|
        row = []
        row << activity.project.try(:name)
        row << activity.name
        row << activity.description
        row << activity.provider.try(:name)
        row << activity.spend
        row << activity.spend_q4_prev
        row << activity.spend_q1
        row << activity.spend_q2
        row << activity.spend_q3
        row << activity.budget
        row << activity.budget_q4_prev
        row << activity.budget_q1
        row << activity.budget_q2
        row << activity.budget_q3
        row << activity.locations.map{|l| l.short_display}.join(',')
        row << activity.beneficiaries.map{|l| l.short_display}.join(',')
        row << ''
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

      activity.csv_project_name        = row[0].try(:strip)
      activity.name                    = row[1].try(:strip)
      activity.description             = row[2].try(:strip)
      activity.csv_provider            = row[3].try(:strip)
      activity.spend                   = row[4].try(:strip)
      activity.spend_q4_prev           = row[5].try(:strip)
      activity.spend_q1                = row[6].try(:strip)
      activity.spend_q2                = row[7].try(:strip)
      activity.spend_q3                = row[8].try(:strip)
      activity.budget                  = row[9].try(:strip)
      activity.budget_q4_prev          = row[10].try(:strip)
      activity.budget_q1               = row[11].try(:strip)
      activity.budget_q2               = row[12].try(:strip)
      activity.budget_q3               = row[13].try(:strip)
      activity.csv_districts           = row[14].try(:strip)
      activity.csv_beneficiaries       = row[14].try(:strip)
      activity.text_for_beneficiaries  = row[15].try(:strip)
      activity.text_for_targets        = row[16].try(:strip)
      activity.start_date              = row[17].try(:strip)
      activity.end_date                = row[18].try(:strip)

      # associations
      if activity.csv_project_name.present?
        # find project by name
        project = response.projects.find_by_name(activity.csv_project_name)
      else
        # find project by project id if present (when uploading activities for project)
        project = project_id.present? ? Project.find_by_id(project_id) : nil
      end

      activity.project             = project if project
      provider                     = Organization.find_by_name(activity.csv_provider)
      activity.provider            = provider if provider
      activity.locations           = activity.csv_districts.to_s.split(',').
                                      map{|l| Location.find_by_short_display(l.strip)}.compact
      activity.beneficiaries       = activity.csv_beneficiaries.to_s.split(',').
                                      map{|b| Beneficiary.find_by_short_display(b.strip)}.compact

      activity.save

      activities << activity
    end

    activities
  end


  def has_budget_or_spend?
    return true if self.spend.present?
    return true if self.budget.present?
  end

  def possible_duplicate?
    self.class.canonical_with_scope.find(:first, :conditions => {:id => id}).nil?
  end

  def budget_district_coding_adjusted
    district_coding_adjusted(CodingBudgetDistrict, coding_budget_district, budget)
  end

  def spend_district_coding_adjusted
    district_coding_adjusted(CodingSpendDistrict, coding_spend_district, spend)
  end

  def budget_stratprog_coding
    virtual_codes(HsspBudget, coding_budget, STRAT_PROG_TO_CODES_FOR_TOTALING)
  end

  def spend_stratprog_coding
    virtual_codes(HsspSpend, coding_spend, STRAT_PROG_TO_CODES_FOR_TOTALING)
  end

  def budget_stratobj_coding
    virtual_codes(HsspBudget, coding_budget, STRAT_OBJ_TO_CODES_FOR_TOTALING)
  end

  def spend_stratobj_coding
    virtual_codes(HsspSpend, coding_spend, STRAT_OBJ_TO_CODES_FOR_TOTALING)
  end

  # convenience
  def implementer
    provider
  end

  def organization_name
    organization.name
  end


  def coding_budget_classified? #purposes
    !data_response.request.purposes? || CodingTree.new(self, CodingBudget).valid?
  end

  def coding_budget_cc_classified? #inputs
    !data_response.request.inputs? || CodingTree.new(self, CodingBudgetCostCategorization).valid?
  end

  def coding_budget_district_classified? #locations
    !data_response.request.locations? || locations.empty? || CodingTree.new(self, CodingBudgetDistrict).valid?
  end

  def service_level_budget_classified? #service levels
    !data_response.request.service_levels? || CodingTree.new(self, ServiceLevelBudget).valid?
  end

  def coding_spend_classified?
    !data_response.request.purposes? || CodingTree.new(self, CodingSpend).valid?
  end

  def coding_spend_cc_classified?
    !data_response.request.inputs? || CodingTree.new(self, CodingSpendCostCategorization).valid?
  end

  def coding_spend_district_classified?
    !data_response.request.locations? || locations.empty? || CodingTree.new(self, CodingSpendDistrict).valid?
  end

  def service_level_spend_classified?
    !data_response.request.service_levels? || CodingTree.new(self, ServiceLevelSpend).valid?
  end

  def budget_classified?
    return true if self.budget.blank?
    coding_budget_classified? &&
    coding_budget_district_classified? &&
    coding_budget_cc_classified? &&
    service_level_budget_classified?
  end

  def spend_classified?
    return true if self.spend.blank?
    coding_spend_classified? &&
    coding_spend_district_classified? &&
    coding_spend_cc_classified? &&
    service_level_spend_classified?
  end

  # An activity can be considered classified if at least one of these are populated.
  def classified?
    (budget_classified? && !budget.blank?) || (spend_classified? && !spend.blank?)
  end

  # TODO: spec
  def classified_by_type?(coding_type)
    case coding_type
    when 'CodingBudget'
      coding_budget_classified?
    when 'CodingBudgetDistrict'
      coding_budget_district_classified?
    when 'CodingBudgetCostCategorization'
      coding_budget_cc_classified?
    when 'ServiceLevelBudget'
      service_level_budget_classified?
    when 'CodingSpend'
      coding_spend_classified?
    when 'CodingSpendDistrict'
      coding_spend_district_classified?
    when 'CodingSpendCostCategorization'
      coding_spend_cc_classified?
    when 'ServiceLevelSpend'
      service_level_spend_classified?
    else
      raise "Unknown type #{coding_type}".to_yaml
    end
  end

  def update_classified_amount_cache(type)
    set_classified_amount_cache(type)
    self.save(false) # save the activity even if it's approved
  end

  # Updates classified amount caches if budget or spend have been changed
  def update_all_classified_amount_caches
    if budget_changed?
      [CodingBudget, CodingBudgetDistrict,
         CodingBudgetCostCategorization, ServiceLevelBudget].each do |type|
        set_classified_amount_cache(type)
      end
    end
    if spend_changed?
      [CodingSpend, CodingSpendDistrict,
         CodingSpendCostCategorization, ServiceLevelSpend].each do |type|
        set_classified_amount_cache(type)
      end
    end
  end

  def coding_budget_sum_in_usd
    coding_budget.with_code_ids(Mtef.roots).sum(:cached_amount_in_usd)
  end

  def coding_spend_sum_in_usd
    coding_spend.with_code_ids(Mtef.roots).sum(:cached_amount_in_usd)
  end

  def coding_budget_district_sum_in_usd(district)
    coding_budget_district.with_code_id(district).sum(:cached_amount_in_usd)
  end

  def coding_spend_district_sum_in_usd(district)
    coding_spend_district.with_code_id(district).sum(:cached_amount_in_usd)
  end

  def virtual_codes(klass, code_assignments, code_ids_maping)
    assignments = []

    code_ids_maping.each do |code_name, code_ids|
      selected = code_assignments.select {|ca| code_ids.include?(ca.code.external_id)}
      code = Code.find_by_short_display(code_name)
      amount = selected.sum{|ca| ca.cached_amount}
      assignments << fake_ca(klass, code, amount)
    end

    assignments
  end

  # This method copies budget code assignments to spend when user has chosen
  # to use budget codings for expenditure: All spend mappings are copied.
  def copy_budget_codings_to_spend(coding_types = BUDGET_CODING_CLASSES)
    coding_types.each do |budget_coding_type|
      spend_coding_type = CLASSIFICATION_MAPPINGS[budget_coding_type]
      klass             = spend_coding_type.constantize

      delete_existing_code_assignments_by_type(spend_coding_type)

      # copy across the ratio, not just the amount
      code_assignments.with_type(budget_coding_type).each do |ca|
        if spend && spend > 0
          amount = (ca.amount && budget && budget > 0) ?  spend * ca.amount / budget : nil
          spend_ca = fake_ca(klass, ca.code, amount, ca.percentage)
          spend_ca.save!
        end
      end

      self.update_classified_amount_cache(klass)
    end

    true
  end

  def derive_classifications_from_sub_implementers!(coding_type)
    klass = coding_type.constantize
    location_amounts = {}

    delete_existing_code_assignments_by_type(coding_type)
    self.locations = [] # delete all locations

    sub_activity_district_code_assignments(coding_type).each do |ca|
      location_amounts[ca.code] ||= 0
      location_amounts[ca.code] += ca.amount
    end

    location_amounts.each do |location, amount|
      self.locations << location
      fake_ca(klass, location, amount).save!
    end

    self.update_classified_amount_cache(klass)
  end

  def coding_progress
    coded = 0
    coded += 1 if coding_budget_classified?
    coded += 1 if coding_budget_district_classified?
    coded += 1 if coding_budget_cc_classified?
    coded += 1 if service_level_budget_classified?
    coded += 1 if coding_spend_classified?
    coded += 1 if coding_spend_district_classified?
    coded += 1 if coding_spend_cc_classified?
    coded += 1 if service_level_spend_classified?
    progress = ((coded.to_f / 8) * 100).to_i # dont need decimal places
  end

  def deep_clone
    clone = self.clone
    # HABTM's
    %w[locations organizations beneficiaries].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc))
    end
    # has-many's
    %w[code_assignments sub_activities funding_sources outputs].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc).collect { |obj| obj.clone })
    end
    clone
  end

  def classification_amount(classification_type)
    case classification_type.to_s
    when 'CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization', 'ServiceLevelBudget'
      budget
    when 'CodingSpend', 'CodingSpendDistrict', 'CodingSpendCostCategorization', 'ServiceLevelSpend'
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

  def check_projects_budget_and_spend?
    return true if budget.nil? && spend.nil?
    return true if budget.present? && spend.present? &&
                   type == "OtherCost" && project.nil?
    return true if actual_budget <= (project.budget || 0) &&
                   actual_spend <= (project.spend || 0) &&
                   actual_quarterly_spend_check? &&
                   actual_quarterly_budget_check?

    return false
  end

  def actual_spend
    (spend || 0 )
  end

  def actual_budget
    (budget || 0 )
  end

  def actual_quarterly_spend_check?
    return true if (spend_q1 || 0) <= (project.spend_q1 || 0) &&
                   (spend_q2 || 0) <= (project.spend_q2 || 0) &&
                   (spend_q3 || 0) <= (project.spend_q3 || 0) &&
                   (spend_q4 || 0) <= (project.spend_q1 || 0)
    return false
  end

  def actual_quarterly_budget_check?
    return true if (budget_q1 || 0) <= (project.budget_q1 || 0) &&
                   (budget_q2 || 0) <= (project.budget_q2 || 0) &&
                   (budget_q3 || 0) <= (project.budget_q3 || 0) &&
                   (budget_q4 || 0) <= (project.budget_q4 || 0)

    return false
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

  private

    def self.file_upload_columns(response)
      ["Project Name", "Activity Name", "Activity Description",
       "Provider", "Past Expenditure",
       "#{response.spend_quarters_months('q1')} Spend",
       "#{response.spend_quarters_months('q2')} Spend",
       "#{response.spend_quarters_months('q3')} Spend",
       "#{response.spend_quarters_months('q4')} Spend",
       "Current Budget",
        "#{response.budget_quarters_months('q1')} Budget",
        "#{response.budget_quarters_months('q2')} Budget",
        "#{response.budget_quarters_months('q3')} Budget",
        "#{response.budget_quarters_months('q4')} Budget",
       "Districts", "Beneficiaries", "Outputs / Targets", "Start Date", "End Date"]
    end

    def delete_existing_code_assignments_by_type(coding_type)
      CodeAssignment.delete_all(["activity_id = ? AND type = ?", self.id, coding_type])
    end

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
      self.send("#{type}_amount=", coding_tree.total)
    end

    def district_coding_adjusted(klass, assignments, amount)
      if assignments.present?
        assignments
      elsif sub_activities.present?
        district_codings_from_sub_activities(klass)
      elsif amount
        locations.map{|location| fake_ca(klass, location, amount / locations.size)}
      else
        []
      end
    end

    def district_codings_from_sub_activities(klass)
      code_assignments = sub_activity_district_code_assignments_if_complete(klass.name)

      location_amounts = {}
      code_assignments.each do |ca|
        location_amounts[ca.code] = 0 unless location_amounts[ca.code]
        location_amounts[ca.code] += ca.cached_amount
      end

      location_amounts.map{|location, amount| fake_ca(klass, location, amount)}
    end

    def sub_activity_district_code_assignments_if_complete(coding_type)
      case coding_type
      when 'CodingBudgetDistrict'
        cas = sub_activities.collect{|sub_activity| sub_activity.budget_district_coding_adjusted }
      when 'CodingSpendDistrict'
        cas = sub_activities.collect{|sub_activity| sub_activity.spend_district_coding_adjusted }
      end
      puts id if cas == nil
      return [] if cas.include?([])
      cas.flatten
    end

    def sub_activity_district_code_assignments(coding_type)
      case coding_type
      when 'CodingBudgetDistrict'
        sub_activities.collect{|sub_activity| sub_activity.budget_district_coding_adjusted }
      when 'CodingSpendDistrict'
        sub_activities.collect{|sub_activity| sub_activity.spend_district_coding_adjusted }
      end.flatten
    end

    # removes code assignments for non-existing locations for this activity
    def remove_district_codings
      activity_id           = self.id
      location_ids          = locations.map(&:id)
      code_assignment_types = [CodingBudgetDistrict, CodingSpendDistrict]
      deleted_count = CodeAssignment.delete_all(["activity_id = :activity_id AND type IN (:code_assignment_types) AND code_id NOT IN (:location_ids)",
                        {:activity_id => activity_id,
                         :code_assignment_types => code_assignment_types.map{|ca| ca.to_s},
                         :location_ids => location_ids}])

      # only if there are deleted code assignments, update the district cached amounts
      if deleted_count > 0
        code_assignment_types.each do |type|
          set_classified_amount_cache(type)
        end
      end
    end

    def approved_activity_cannot_be_changed
      errors.add(:base, "Activity was approved by SysAdmin and cannot be changed") if changed? and approved and changed != ["approved"]
    end

    #currency is still derived from the parent project or DR
    def update_cached_usd_amounts
      if self.currency
        if (rate = Money.default_bank.get_rate(self.currency, :USD))
          self.budget_in_usd = (budget || 0) * rate
          self.spend_in_usd  = (spend || 0)  * rate
        end
      end
    end

    # setting the total amount if the quarterlys are set
    def set_total_amounts
      ["budget", "spend"].each do |type|
        amount = total_amount_of_quarters(type)
        self.send(:"#{type}=", amount) if amount > 0
      end
    end

    def fake_ca(klass, code, amount, percentage = nil)
      klass.new(:activity => self, :code => code,
                :amount => amount, :percentage => percentage,
                :cached_amount => amount)
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
    
    def strip_leading_spaces
      self.name = self.name.strip if self.name 
      self.description = self.description.strip if self.description
    end
end







# == Schema Information
#
# Table name: activities
#
#  id                                    :integer         not null, primary key
#  name                                  :string(255)
#  created_at                            :datetime
#  updated_at                            :datetime
#  provider_id                           :integer         indexed
#  description                           :text
#  type                                  :string(255)     indexed
#  budget                                :decimal(, )
#  spend_q1                              :decimal(, )
#  spend_q2                              :decimal(, )
#  spend_q3                              :decimal(, )
#  spend_q4                              :decimal(, )
#  start_date                            :date
#  end_date                              :date
#  spend                                 :decimal(, )
#  text_for_provider                     :text
#  text_for_targets                      :text
#  text_for_beneficiaries                :text
#  spend_q4_prev                         :decimal(, )
#  data_response_id                      :integer         indexed
#  activity_id                           :integer         indexed
#  approved                              :boolean
#  CodingBudget_amount                   :decimal(, )     default(0.0)
#  CodingBudgetCostCategorization_amount :decimal(, )     default(0.0)
#  CodingBudgetDistrict_amount           :decimal(, )     default(0.0)
#  CodingSpend_amount                    :decimal(, )     default(0.0)
#  CodingSpendCostCategorization_amount  :decimal(, )     default(0.0)
#  CodingSpendDistrict_amount            :decimal(, )     default(0.0)
#  budget_q1                             :decimal(, )
#  budget_q2                             :decimal(, )
#  budget_q3                             :decimal(, )
#  budget_q4                             :decimal(, )
#  budget_q4_prev                        :decimal(, )
#  comments_count                        :integer         default(0)
#  sub_activities_count                  :integer         default(0)
#  spend_in_usd                          :decimal(, )     default(0.0)
#  budget_in_usd                         :decimal(, )     default(0.0)
#  project_id                            :integer
#  ServiceLevelBudget_amount             :decimal(, )     default(0.0)
#  ServiceLevelSpend_amount              :decimal(, )     default(0.0)
#  budget2                               :decimal(, )
#  budget3                               :decimal(, )
#  budget4                               :decimal(, )
#  budget5                               :decimal(, )
#  am_approved                           :boolean
#  user_id                               :integer
#  am_approved_date                      :date
#

