require 'lib/ActAsDataElement'
require 'lib/BudgetSpendHelpers'
require 'validators'

class Activity < ActiveRecord::Base
  ### Constants
  FILE_UPLOAD_COLUMNS = %w[project_name name description start_date end_date
                           text_for_targets text_for_beneficiaries text_for_provider
                           spend spend_q4_prev spend_q1 spend_q2 spend_q3 spend_q4
                           budget budget2 budget3 budget_q4_prev budget_q1 budget_q2
                           budget_q3 budget_q4]

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

  ### Includes
  include ActAsDataElement
  include BudgetSpendHelpers
  acts_as_commentable
  configure_act_as_data_element

  ### Attributes
  attr_accessible :text_for_provider, :text_for_beneficiaries, :project_id,
                  :text_for_targets, :name, :description, :start_date, :end_date,
                  :approved, :budget, :budget2, :budget3, :spend,
                  :spend_q1, :spend_q2, :spend_q3, :spend_q4, :spend_q4_prev,
                  :budget_q1, :budget_q2, :budget_q3, :budget_q4, :budget_q4_prev,
                  :beneficiary_ids, :location_ids, :provider_id,
                  :sub_activities_attributes, :organization_ids, :funding_sources_attributes

  ### Associations
  belongs_to :provider, :foreign_key => :provider_id, :class_name => "Organization"
  belongs_to :data_response
  belongs_to :project
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :organizations # organizations targeted by this activity / aided
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity
  has_many :sub_activities, :class_name => "SubActivity",
                            :foreign_key => :activity_id,
                            :dependent => :destroy
  has_many :sub_implementers, :through => :sub_activities, :source => :provider
  has_many :funding_sources
  has_many :codes, :through => :code_assignments
  has_many :code_assignments, :dependent => :destroy
  has_many :coding_budget
  has_many :coding_budget_cost_categorization
  has_many :coding_budget_district
  has_many :coding_spend
  has_many :coding_spend_cost_categorization
  has_many :coding_spend_district

  ### Nested attributes
  accepts_nested_attributes_for :sub_activities, :allow_destroy => true
  accepts_nested_attributes_for :funding_sources, :allow_destroy => true, 
    :reject_if => lambda {|fs| fs["funding_flow_id"].blank? }

  ### Delegates
  delegate :organization, :to => :data_response
  delegate :currency, :to => :project, :allow_nil => true
  delegate :data_request, :to => :data_response

  ### Validations
  validate :approved_activity_cannot_be_changed
  validates_presence_of :description
  validates_presence_of :data_response_id, :project_id, :unless => Proc.new {|model| model.class.to_s == 'SubActivity'}
  validates_numericality_of :spend, :if => Proc.new {|model| !model.spend.blank?}, :unless => Proc.new {|model| model.activity_id}
  validates_numericality_of :budget, :if => Proc.new {|model| !model.budget.blank?}, :unless => Proc.new {|model| model.activity_id}
  #validates_date :start_date, :unless => Proc.new {|model| model.activity_id}
  #validates_date :end_date, :unless => Proc.new {|model| model.activity_id}
  #validates_dates_order :start_date, :end_date, :message => "Start date must come before End date.", :unless => Proc.new {|model| model.activity_id}

  ### Callbacks
  before_save :update_cached_usd_amounts
  before_update :remove_district_codings
  before_update :update_all_classified_amount_caches
  after_save  :update_counter_cache
  after_destroy :update_counter_cache

  ### Named scopes
  # TODO: spec
  named_scope :roots,             {:conditions => "activities.type IS NULL" }
  named_scope :greatest_first,    {:order => "activities.budget DESC" }
  named_scope :with_type,         lambda { |type| {:conditions => ["activities.type = ?", type]} }
  named_scope :only_simple,       { :conditions => ["activities.type IS NULL
                                    OR activities.type IN (?)", ["OtherCost"]] }
  named_scope :with_a_project,    { :conditions => "activities.id IN (SELECT activity_id FROM activities_projects)" }
  named_scope :without_a_project, { :conditions => "project_id IS NULL" }
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

  #def description
    #d = read_attribute(:description)
    #d.present? ? d : 'No description'
  #end

  def self.unclassified
    self.find(:all).select {|a| !a.classified?}
  end

  def self.jawp_activities
    Activity.only_simple.find(:all,
      :include => [:locations, :provider, :organizations,
                  :beneficiaries, {:data_response => :organization}])
  end

  def self.download_template
    FasterCSV.generate do |csv|
      csv << Activity::FILE_UPLOAD_COLUMNS
    end
  end

  def self.create_from_file(doc, data_response)
    saved, errors = 0, 0
    doc.each do |row|
      attributes = row.to_hash
      project = Project.find_by_name(attributes.delete('project_name'))
      attributes.merge!(:project_id => project.id) if project
      activity = data_response.activities.new(attributes)
      activity.save ? (saved += 1) : (errors += 1)
    end
    return saved, errors
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

  # TODO remove
  #def districts
    #project.locations
  #end

  def coding_budget_classified?
    budget.blank? || budget == self.CodingBudget_amount
  end

  def coding_budget_cc_classified?
    budget.blank? || budget == self.CodingBudgetCostCategorization_amount
  end

  def coding_budget_district_classified?
    budget.blank? || locations.empty? || budget == self.CodingBudgetDistrict_amount
  end

  def service_level_budget_classified?
    budget.blank? || budget == self.ServiceLevelBudget_amount
  end

  def coding_spend_classified?
    spend.blank? || spend == self.CodingSpend_amount
  end

  def coding_spend_cc_classified?
    spend.blank? || spend == self.CodingSpendCostCategorization_amount
  end

  def coding_spend_district_classified?
    spend.blank? || locations.empty? || spend == self.CodingSpendDistrict_amount
  end

  def service_level_spend_classified?
    spend.blank? || spend == self.ServiceLevelSpend_amount
  end

  def budget_classified?
    coding_budget_classified? &&
    coding_budget_district_classified? &&
    coding_budget_cc_classified? &&
    service_level_budget_classified?
  end

  def spend_classified?
    coding_spend_classified? &&
    coding_spend_district_classified? &&
    coding_spend_cc_classified? &&
    service_level_spend_classified?
  end

  def classified?
    budget_classified? && spend_classified?
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

    sub_activity_district_code_assignments(coding_type).each do |ca|
      if locations.include?(ca.code)
        location_amounts[ca.code] = 0 unless location_amounts[ca.code]
        location_amounts[ca.code] += ca.amount
      end
    end

    # create new district assignments
    location_amounts.each{|location, amount| fake_ca(klass, location, amount).save!}

    self.update_classified_amount_cache(klass)
  end

  def coding_progress
    coded = 0
    coded += 1 if coding_budget_classified?
    coded += 1 if coding_budget_district_classified?
    coded += 1 if coding_budget_cc_classified?
    coded += 1 if coding_spend_classified?
    coded += 1 if coding_spend_district_classified?
    coded += 1 if coding_spend_cc_classified?
    progress = (coded.to_f / 6) * 100
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

  private

    def delete_existing_code_assignments_by_type(coding_type)
      CodeAssignment.delete_all(["activity_id = ? AND type = ?", self.id, coding_type])
    end

    def update_counter_cache
      if (dr = self.data_response)
        dr.activities_count = dr.activities.only_simple.count
        dr.activities_without_projects_count = dr.activities.roots.without_a_project.count
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
      code_assignments = sub_activity_district_code_assignments(klass.name)

      location_amounts = {}
      code_assignments.each do |ca|
        location_amounts[ca.code] = 0 unless location_amounts[ca.code]
        location_amounts[ca.code] += ca.cached_amount
      end

      location_amounts.map{|location, amount| fake_ca(klass, location, amount)}
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
      errors.add(:approved, "approved activity cannot be changed") if changed? and approved and changed != ["approved"]
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

    def fake_ca(klass, code, amount, percentage = nil)
      klass.new(:activity => self, :code => code,
                :amount => amount, :percentage => percentage,
                :cached_amount => amount)
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
#  budget_percentage                     :decimal(, )
#  spend_percentage                      :decimal(, )
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
#  budget2                               :decimal(, )
#  budget3                               :decimal(, )
#

