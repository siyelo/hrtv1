require 'validators'

class Activity < ActiveRecord::Base
  include CurrencyNumberHelper
  include Activity::Classification
  include Activity::Validations
  include AutocreateHelper
  include BudgetSpendHelper

  ### Constants
  MAX_NAME_LENGTH = 64
  HUMANIZED_ATTRIBUTES = {
    :implementer_splits => "Implementers",
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
    :approved, :am_approved, :budget, :spend,
    :beneficiary_ids, :provider_id, :implementer_splits_attributes,
    :organization_ids, :csv_project_name,
    :csv_provider, :csv_beneficiaries, :csv_targets, :targets_attributes,
    :outputs_attributes, :am_approved_date, :user_id, :data_response_id,
    :planned_for_gor_q1, :planned_for_gor_q2, :planned_for_gor_q3,
    :planned_for_gor_q4

  ### Associations
  belongs_to :provider, :foreign_key => :provider_id,
    :class_name => "Organization" # FIXME: deprecate plox k thx
  belongs_to :data_response
  belongs_to :response, :foreign_key => :data_response_id,
    :class_name => "DataResponse" #convenience.
  belongs_to :project
  belongs_to :user
  has_and_belongs_to_many :organizations # organizations targeted by this activity / aided
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity
  has_many :implementer_splits, :dependent => :delete_all
  has_many :implementers, :through => :implementer_splits, :source => :organization
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
  has_many :budget_purposes, :dependent => :destroy,
    :class_name => 'CodingBudget'
  has_many :budget_inputs, :dependent => :destroy,
    :class_name => 'CodingBudgetCostCategorization'
  has_many :budget_locations, :dependent => :destroy,
    :class_name => 'CodingBudgetDistrict'
  has_many :spend_purposes, :dependent => :destroy,
    :class_name => 'CodingSpend'
  has_many :spend_inputs, :dependent => :destroy,
    :class_name => 'CodingSpendCostCategorization'
  has_many :spend_locations, :dependent => :destroy,
    :class_name => 'CodingSpendDistrict'
  has_many :targets, :dependent => :destroy
  has_many :outputs, :dependent => :destroy
  has_many :leaf_budget_purposes, :dependent => :destroy,
    :class_name => 'CodingBudget',
    :conditions => ["code_assignments.sum_of_children = 0"]
  has_many :leaf_spend_purposes, :dependent => :destroy,
    :class_name => 'CodingSpend',
    :conditions => ["code_assignments.sum_of_children = 0"]
  has_many :leaf_budget_inputs, :dependent => :destroy,
    :class_name => 'CodingBudgetCostCategorization',
    :conditions => ["code_assignments.sum_of_children = 0"]
  has_many :leaf_spend_inputs, :dependent => :destroy,
    :class_name => 'CodingSpendCostCategorization',
    :conditions => ["code_assignments.sum_of_children = 0"]

  ### Nested attributes
  accepts_nested_attributes_for :implementer_splits, :allow_destroy => true,
    :reject_if => Proc.new { |attrs| attrs['organization_mask'].blank? }
  accepts_nested_attributes_for :targets, :allow_destroy => true,
    :reject_if => Proc.new { |attrs| attrs['description'].blank? }
  accepts_nested_attributes_for :outputs, :allow_destroy => true,
    :reject_if => Proc.new { |attrs| attrs['description'].blank? }

  ### Callbacks
  before_validation :strip_input_fields
  before_save       :update_implementer_cache
  before_save       :auto_create_project
  before_save       :update_cached_usd_amounts
  after_destroy     :restart_response_if_all_activities_removed
  before_update     :update_all_classified_amount_caches

  ### Delegates
  delegate :currency, :to => :project, :allow_nil => true
  delegate :data_request, :to => :data_response
  delegate :organization, :to => :data_response

  ### Validations
  # also see validations in BudgetSpendHelper
  validate :approved_activity_cannot_be_changed
  validate :cannot_approve_unclassified_activity
  validate :validate_implementers_uniqueness
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :project_id, :if => :is_activity?,
    :unless => Proc.new{ |a| a.project && a.project.new_record? }
  validates_presence_of :data_response_id
  validates_length_of :name, :within => 3..MAX_NAME_LENGTH

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

  def self.approve_all_budgets(ids, user_id)
    Activity.update_all({:user_id => user_id, :am_approved => true,
                         :am_approved_date => Time.now}, ["id IN (?)", ids])
  end

  ### Instance Methods

  def update_attributes(params)
    update_classifications_from_params(params)
    super(params)
  end

  # This method calculates the totals of the sub-activities budget/spend
  # This is done because an activities budget/spend is the total of
  # their implementer_splits budget/spend
  def implementer_splits_totals(method)
    implementer_splits.reject { |sa| sa.marked_for_destruction? }.
      map { |sa| sa.send(method) }.compact.sum || 0
  end

  #preventing user from writing
  def budget=(amount)
    raise Hrt::FieldDeprecated
  end

  #preventing user from writing
  def spend=(amount)
    raise Hrt::FieldDeprecated
  end

  def am_approved?(user = nil)
    user && user.sysadmin? ? false : read_attribute(:am_approved)
  end

  def to_s
    name
  end

  def human_name
    "Activity"
  end

  def organization_name
    organization.name
  end

  # synchronously update classification tree cached amounts
  def update_classified_amount_cache(type)
    # disable update_all_classified_amount_caches
    # callback to be run again on save !!
    Activity.before_update.reject! do |callback|
      callback.method.to_s == 'update_all_classified_amount_caches'
    end
    set_classified_amount_cache(type)
    self.save(false) # save the activity even if it's approved
  end
  handle_asynchronously :update_classified_amount_cache

  # Updates classified amount caches if budget or spend have been changed
  def update_all_classified_amount_caches
    if budget_changed?
      [CodingBudget, CodingBudgetDistrict, CodingBudgetCostCategorization].each do |type|
        update_classified_amount_cache(type)
      end
    end
    if spend_changed?
      [CodingSpend, CodingSpendDistrict, CodingSpendCostCategorization].each do |type|
        update_classified_amount_cache(type)
      end
    end
  end

  def deep_clone
    clone = self.clone
    %w[organizations beneficiaries].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc))
    end
    # has-many's
    %w[code_assignments implementer_splits targets].each do |assoc|
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

  def implementer_splits_each_have_defined_districts?(coding_type)
    !implementer_split_district_code_assignments_if_complete(coding_type).empty?
  end

  def amount_for_provider(organization, field)
    if implementer_splits.empty?
      return self.send(field) if self.organization == organization
    else
      sum = 0
      implementer_splits.select{ |a| a.organization == organization }.each do |a|
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

  def implementer_splits_total(amount_method)
    smart_sum(implementer_splits, amount_method)
  end

  #saves the subactivities totals into the buget/spend fields
  def update_implementer_cache
    [:budget, :spend].each do |method|
      write_attribute(method, implementer_splits_totals(method))
    end
  end

  def implementer_splits_valid?
    valid = true
    self.implementer_splits.each do |is|
      if !is.valid?
        valid = false
        break
      end
    end
    valid
  end

  protected

    # intercept the classifications and process using the bulk classification update API
    # FIXME: the CodingBlah class method saves the activity in the middle of this update... Not good.
    def update_classifications_from_params(params)
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
      end
    end

  private
    def set_classified_amount_cache(type)
      coding_tree = CodingTree.new(self, type)
      coding_tree.set_cached_amounts!
      self.send("#{get_valid_attribute_name(type)}=".to_sym, coding_tree.valid?)
    end

    def approved_activity_cannot_be_changed
      message = "Activity was approved by SysAdmin and cannot be changed"
      errors.add(:base, message) if changed? && approved? && !changed.include?("approved")
    end

    def cannot_approve_unclassified_activity
      message = "Cannot approve unclassified #{self.class.to_s.titleize}"
      errors.add(:base, message) if changed? && !classified? && changed.include?("approved")
    end

    def is_activity?
      self.class.eql?(Activity)
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
      else raise "Unknown type #{type}".to_yaml
      end
    end

    def auto_create_project
      if project_id == AUTOCREATE
        project = data_response.projects.find_by_name(name)
        unless project
          self_funder = FundingFlow.new(:from => self.organization)
          project = Project.new(:name => name, :start_date => Time.now,
            :end_date => Time.now + 1.year, :data_response => data_response,
            :in_flows => [self_funder])
          project.save(false)
        end
        self.project = project
      end
    end

    def restart_response_if_all_activities_removed
      # use .length since .empty? uses counter cache that isnt updated yet.
      response.restart! if self.response.activities.length == 0
    end

    def validate_implementers_uniqueness
      implementer_orgs = implementer_splits.select do |e|
        !e.marked_for_destruction?
      end.map(&:organization_id)

      if implementer_orgs.length != implementer_orgs.uniq.length
        # Reject splits where Org Id appears once & find unique ID of duplicates
        dup_ids = implementer_orgs.reject {|org_id| implementer_orgs.one? { |id| id == org_id } }
        # Find implmenter splits with an organization that has been duplicated
        duplicates = implementer_splits.select { |is| dup_ids.include?(is.organization_id) }
        self.errors.add_to_base("Duplicate Implementers")
        duplicates.each do |dup|
          dup.errors.add_to_base("Duplicate Implementer")
        end
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
#  spend                        :decimal(, )
#  text_for_provider            :text
#  text_for_beneficiaries       :text
#  data_response_id             :integer         indexed
#  activity_id                  :integer         indexed
#  approved                     :boolean
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
#  planned_for_gor_q1           :boolean
#  planned_for_gor_q2           :boolean
#  planned_for_gor_q3           :boolean
#  planned_for_gor_q4           :boolean
#

