require 'lib/BudgetSpendHelpers'
require 'validators'

class Activity < ActiveRecord::Base

  ### Includes
  include BudgetSpendHelpers
  include NumberHelper
  include Activity::Classification


  ### Constants
  FILE_UPLOAD_COLUMNS = ["Project Name", "Activity Name", "Activity Description", "Provider", "Past Expenditure",
                         "Current Budget", "Districts", "Beneficiaries", "Outputs / Targets"]


  ### Attribute Protection
  attr_accessible :text_for_provider, :text_for_beneficiaries, :project_id,
    :text_for_targets, :name, :description, :approved, :am_approved, :spend,
    :budget, :beneficiary_ids, :location_ids, :provider_id,
    :sub_activities_attributes, :organization_ids, :funding_sources_attributes,
    :csv_project_name, :csv_provider, :csv_districts, :csv_beneficiaries,
    :am_approved_date, :user_id


  ### Associations
  belongs_to :provider, :foreign_key => :provider_id, :class_name => "Organization"
  belongs_to :data_response
  belongs_to :project
  belongs_to :user
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :organizations # organizations targeted by this activity / aided
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity
  has_many :sub_activities, :class_name => "SubActivity",
             :foreign_key => :activity_id, :dependent => :destroy
  has_many :sub_implementers, :through => :sub_activities,
             :source => :provider, :dependent => :destroy
  has_many :funding_sources, :dependent => :destroy
  has_many :codes, :through => :code_assignments
  has_many :code_assignments, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :coding_budget, :dependent => :destroy
  has_many :coding_budget_cost_categorization, :dependent => :destroy
  has_many :coding_budget_district, :dependent => :destroy
  has_many :coding_spend, :dependent => :destroy
  has_many :coding_spend_cost_categorization, :dependent => :destroy
  has_many :coding_spend_district, :dependent => :destroy

  ### Class-Level Method Invocations
  strip_commas_from_all_numbers


  ### Scopes
  # TODO: spec
  named_scope :roots,             {:conditions => "activities.type IS NULL" }
  named_scope :greatest_first,    {:order => "activities.budget DESC" }
  named_scope :with_type,         lambda { |type| {:conditions =>
                                                   ["activities.type = ?", type]} }
  named_scope :only_simple,       { :conditions => ["activities.type IS NULL
                                    OR activities.type IN (?)", ["OtherCost"]] }
  named_scope :with_request,      lambda {|request| {  :select => 'DISTINCT activities.*',
                                    :joins => 'INNER JOIN data_responses ON
                                             data_responses.id = activities.data_response_id',
                                    :conditions => ['data_responses.data_request_id = ?',
                                                    request.id]}}
  named_scope :with_a_project,    { :conditions => "activities.id IN (SELECT activity_id FROM activities_projects)" }
  named_scope :without_a_project, { :conditions => "project_id IS NULL" }
  named_scope :with_organization, { :joins => "INNER JOIN data_responses
                                    ON data_responses.id = activities.data_response_id
                                    INNER JOIN organizations
                                    ON data_responses.organization_id = organizations.id" }
  named_scope :ordered,           { :order => 'description ASC' }
  named_scope :ordered_by_id,     { :order => 'id ASC' }

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
  named_scope :manager_approved, { :conditions => ["am_approved = ?", true] }
  named_scope :sorted,           {:order => "activities.name" }
  named_scope :only_simple_with_request, lambda {|request|
          { :select => 'DISTINCT activities.*',
            :joins => 'INNER JOIN data_responses ON
                       data_responses.id = activities.data_response_id',
            :conditions => ['(activities.type IS NULL
                             OR activities.type IN (?)) AND
                             data_responses.data_request_id = ?',
                             'OtherCost', request.id]}}


  ### Attribute Accessor
  attr_accessor :csv_project_name, :csv_provider, :csv_districts, :csv_beneficiaries


  ### Nested attributes
  accepts_nested_attributes_for :sub_activities, :allow_destroy => true
  accepts_nested_attributes_for :funding_sources, :allow_destroy => true,
    :reject_if => lambda { |fs| fs["funding_flow_id"].blank? }


  ### Delegates
  delegate :currency, :to => :project, :allow_nil => true
  delegate :data_request, :to => :data_response
  delegate :organization, :to => :data_response


  ### Validations
  before_validation :strip_input_fields
  validate :approved_activity_cannot_be_changed
  validates_presence_of :description, :if => Proc.new { |model| model.class.to_s == 'Activity' }
  validates_presence_of :data_response_id
  validates_presence_of :project_id, :unless => Proc.new { |model| model.class.to_s == 'SubActivity' }
    validates_length_of :name, :within => 3..64


  ### Callbacks
  before_save :update_cached_usd_amounts
  before_update :remove_district_codings
  before_update :update_all_classified_amount_caches, :unless => Proc.new { |model| model.class.to_s == 'SubActivity' }
  after_save  :update_counter_cache
  after_destroy :update_counter_cache


  ### Class methods
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

  def self.jawp_activities(request = nil)
    request ? @activities = Activity.only_simple_with_request(request) : @activities = Activity.only_simple
    @activities.find(:all, :include => [:locations, :provider, :organizations,
                                        :beneficiaries, {:data_response => :organization}])
  end

  def self.download_template(activities = [])
    FasterCSV.generate do |csv|
      header_row = Activity::FILE_UPLOAD_COLUMNS
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
        row << activity.budget
        row << activity.locations.map{|l| l.short_display}.join(',')
        row << activity.beneficiaries.map{|l| l.short_display}.join(',')
        row << ''

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


      activity.name                    = row['Activity Name']
      activity.description             = row['Activity Description']
      activity.spend                   = row['Current Expenditure']
      activity.budget                  = row['Current Budget']
      activity.text_for_beneficiaries  = row['Beneficiaries']

      # virtual attributes
      activity.csv_project_name    = row['Project Name']
      activity.csv_provider        = row['Provider']
      activity.csv_districts       = row['Districts']
      activity.csv_beneficiaries   = row['Beneficiaries']
      activity.text_for_targets    = row['Outputs / Targets']

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

  def self.bulk_update(response, activities)
    activities.each_pair do |activity_id, attributes|
      activity = response.activities.find(activity_id)
      activity.attributes = attributes
      activity.budget = attributes[:budget]
      activity.spend = attributes[:spend]
      activity.save
    end
  end

  def convert_to_project_currency(type)
    return 0 if self.send(type).nil?
    amount_type = type
    rate = currency_rate(self.currency, self.project.currency)
    converted_amount = self.send(type) * rate
    return converted_amount
  end

  def has_budget_or_spend?
    return true if spend.present?
    return true if budget.present?
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

  def deep_clone
    clone = self.clone
    # HABTM's
    %w[locations organizations beneficiaries].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc))
    end
    # has-many's
    %w[code_assignments].each do |assoc|
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

  def check_projects_budget_and_spend?
    return true if budget.nil? && spend.nil?
    return true if budget.present? && spend.present? &&
                   type == "OtherCost" && project.nil?
    return true if actual_budget <= (project.budget || 0) &&
                   actual_spend <= (project.spend || 0)
    return false
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

  def title
    description.presence || '(no description)'
  end

  def sub_activities_total_by_type(amount_type, other_currency)
    sub_activities.map { |implementer| implementer.total_by_type(amount_type) }.compact.sum * currency_rate(currency, other_currency)
  end

  def is_simple?
    self.class.eql?(Activity) || self.class.eql?(OtherCost)
  end

  def friendly_name
    name.presence || "Unnamed #{self.class.to_s.titleize}"
  end

  def delegated_to_non_hc_implementer?
    providers = sub_activities.find(:all, :include => :provider).
      map{ |sa| sa.provider }.compact

    providers.delete(organization) # remove self organization
    providers.present? && providers.any?{ |p| !p.health_center? }
  end

  private

    def remove_district_codings
      activity_id = self.id
      location_ids = locations.map(&:id)
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
      puts id if cas == nil
      return [] if cas.include?([])
      cas.flatten
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
      errors.add(:approved, "approved activity cannot be changed") if changed? and approved and changed != ["approved"]
    end

    #currency is still derived from the parent project or DR
    def update_cached_usd_amounts
      if currency
        if (rate = Money.default_bank.get_rate(currency, :USD))
          self.budget_in_usd = (budget || 0) * rate
          self.spend_in_usd  = (spend || 0)  * rate
        end
      end
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

    def strip_input_fields
      self.name = self.name.strip if self.name
      self.description = self.description.strip if self.description
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
#  spend                        :decimal(, )
#  text_for_provider            :text
#  text_for_targets             :text
#  text_for_beneficiaries       :text
#  spend_q4_prev                :decimal(, )
#  data_response_id             :integer         indexed
#  activity_id                  :integer         indexed
#  budget_percentage            :decimal(, )
#  spend_percentage             :decimal(, )
#  approved                     :boolean
#  comments_count               :integer         default(0)
#  sub_activities_count         :integer         default(0)
#  spend_in_usd                 :decimal(, )     default(0.0)
#  budget_in_usd                :decimal(, )     default(0.0)
#  project_id                   :integer
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

