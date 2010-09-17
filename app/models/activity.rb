# == Schema Information
#
# Table name: activities
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  beneficiary            :string(255)
#  target                 :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  provider_id            :integer
#  other_cost_type_id     :integer
#  description            :text
#  type                   :string(255)
#  budget                 :decimal(, )
#  spend_q1               :decimal(, )
#  spend_q2               :decimal(, )
#  spend_q3               :decimal(, )
#  spend_q4               :decimal(, )
#  start                  :date
#  end                    :date
#  spend                  :decimal(, )
#  text_for_provider      :text
#  text_for_targets       :text
#  text_for_beneficiaries :text
#  spend_q4_prev          :decimal(, )
#  data_response_id       :integer
#  activity_id            :integer
#  budget_percentage      :decimal(, )
#  spend_percentage       :decimal(, )
#

require 'lib/ActAsDataElement'

class Activity < ActiveRecord::Base
  VALID_ROOT_TYPES = %w[Mtef Nha Nasa Nsp]

  acts_as_commentable
  include ActAsDataElement
  configure_act_as_data_element

  # Attributes
  attr_accessible :projects, :locations, :text_for_provider,
                  :provider, :name, :description,  :start, :end,
                  :text_for_beneficiaries, :beneficiaries,
                  :text_for_targets, :spend, :spend_q4_prev,
                  :spend_q1, :spend_q2, :spend_q3, :spend_q4,
                  :budget, :approved
  attr_accessor :budget_codes_updates
  attr_accessor :budget_cost_categories_updates
  attr_accessor :budget_district_codes_updates
  attr_accessor :expenditure_codes_updates
  attr_accessor :expenditure_cost_categories_updates
  attr_accessor :expenditure_district_codes_updates
  attr_accessible :budget_cost_categories_updates, :budget_codes_updates,
    :expenditure_codes_updates, :expenditure_cost_categories_updates, :budget_district_codes_updates, :expenditure_district_codes_updates

  # Associations
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :indicators
  has_and_belongs_to_many :locations
  belongs_to :provider, :foreign_key => :provider_id, :class_name => "Organization"
  has_and_belongs_to_many :organizations # organizations targeted by this activity / aided
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity
  # TODO double check these go away from glenn's changes
  #  has_many :code_assignments, :foreign_key => :activity_id, :dependent => :destroy
  #  has_many :codes, :through => :code_assignments
  has_many :sub_activities, :class_name => "SubActivity", :foreign_key => :activity_id
  has_many :budget_codings, :foreign_key => :activity_id, :dependent => :destroy
  has_many :budget_codes, :through => :budget_codings, :source => :code
  has_many :expenditure_codings, :foreign_key => :activity_id, :dependent => :destroy
  has_many :expenditure_codes, :through => :expenditure_codings, :source => :code

  # Callbacks
  after_save :update_budget_codings
  after_save :update_expenditure_codings

  # delegate :providers, :to => :projects
  def valid_providers
    #TODO use delegates_to
    projects.valid_providers
  end

  def organization
    self.data_response.responding_organization
  end

  def districts
    self.projects.collect do |proj|
      proj.locations
    end.flatten.uniq
  end

  def classified
    total_root_codes('budget_codes', budget) == budget &&
    total_root_codes('budget_district_codes', budget) == budget &&
    total_root_codes('budget_cost_categories', budget) == budget &&
    total_root_codes('expenditure_codes', spend) == spend &&
    total_root_codes('expenditure_district_codes', spend) == spend &&
    total_root_codes('expenditure_cost_categories', spend) == spend
  end

  def get_codes(coding_type)
    case coding_type
    when 'budget_codes', 'expenditure_codes'
      Code.valid_activity_codes.roots
    when 'budget_district_codes', 'expenditure_district_codes'
      locations
    when 'budget_cost_categories', 'expenditure_cost_categories'
      CostCategory.roots
    end
  end

  def get_all_code_ids(coding_type)
    case coding_type
    when 'budget_codes', 'expenditure_codes'
      Code.valid_activity_codes.map(&:id)
    when 'budget_district_codes', 'expenditure_district_codes'
      locations.map(&:id)
    when 'budget_cost_categories', 'expenditure_cost_categories'
      CostCategory.all.map(&:id)
    end
  end

  def get_root_code_ids(coding_type)
    case coding_type
    when 'budget_codes', 'expenditure_codes'
      Code.valid_activity_codes.roots.map(&:id)
    when 'budget_district_codes', 'expenditure_district_codes'
      locations.map(&:id)
    when 'budget_cost_categories', 'expenditure_cost_categories'
      CostCategory.roots.map(&:id)
    end
  end

  def get_current_assignments(coding_type, code_ids)
    case coding_type
    when 'budget_codes', 'budget_district_codes', 'budget_cost_categories'
      budget_codings.with_code_ids(code_ids).all
    when 'expenditure_codes', 'expenditure_district_codes', 'expenditure_cost_categories'
      expenditure_codings.with_code_ids(code_ids).all
    end
  end

  def total_root_codes(coding_type, max)
    code_assignments = get_current_assignments(coding_type, get_root_code_ids(coding_type))
    total = 0

    code_assignments.each do |ca|
      if ca.amount.present? && ca.amount > 0
        total += ca.amount
      else
        total += ca.percentage * max / 100
      end
    end

    total
  end

  protected

  def update_coding_attribute_proxy code_assignments, coding_type
    if code_assignments
      code_assignments.delete_if { |key,val| val["amount"].nil? || val["percentage"].nil? }
      code_assignments.delete_if { |key,val| val["amount"].empty? && val["percentage"].empty? }
      selected_codes = code_assignments.nil? ? [] : code_assignments.keys.collect{ |id| Code.find_by_id(id) }

      # TODO change to if its not in selected and has type
      # so we can write useful destry and create callbacks
      clear_old_codings coding_type

      # TODO update all the codings, create the ones that are actually new
      create_klass = create_class_for_coding_type coding_type
      selected_codes.each { |code|  create_klass.create!( :activity => self,
                                      :code => code,
                                      :amount => currency_to_number(code_assignments[code.id.to_s]["amount"]),
                                      :percentage => code_assignments[code.id.to_s]["percentage"] ) unless code.nil? }
    end
  end

  # TODO drive these with hashes instead of if's
  def clear_old_codings coding_type
    coding_to_delete = nil
    if [:budget_codes, :budget_cost_categories, :budget_district_codes].include? coding_type
      coding_to_delete = budget_codings
    elsif [:expenditure_codes, :expenditure_cost_categories, :expenditure_district_codes].include? coding_type
      coding_to_delete = expenditure_codings
    end
    delete_all_codings_by_type coding_to_delete, coding_type
    logger.debug "deleted old codings"
  end

  def delete_all_codings_by_type codings, coding_type
    types_to_delete = nil
    if [:budget_codes, :expenditure_codes].include? coding_type
      types_to_delete = Activity.valid_types_for_code_assignment
    elsif [:budget_cost_categories, :expenditure_cost_categories].include? coding_type
      types_to_delete = Activity.valid_types_for_cost_category_codes
    elsif [:budget_district_codes, :expenditure_district_codes].include? coding_type
      types_to_delete = Activity.valid_types_for_district_codes
    end
    codings.each do |coding|
      coding.delete if types_to_delete.include? coding.code.class
    end
  end

  def create_class_for_coding_type coding_type
    if coding_type == :budget_codes
      BudgetCoding
    elsif coding_type == :budget_cost_categories
      BudgetCoding
    elsif coding_type == :expenditure_codes
      ExpenditureCoding
    elsif coding_type == :expenditure_cost_categories
      ExpenditureCoding
    elsif coding_type == :budget_district_codes
      BudgetCoding
    elsif coding_type == :expenditure_district_codes
      ExpenditureCoding
    end
  end

  private
  def self.valid_types_for_code_assignment
    [Mtef, Nha, Nasa, Nsp]
  end

  def self.valid_types_for_district_codes
    [Location]
  end

  def self.valid_types_for_cost_category_codes
    [CostCategory]
  end

  # trick to help clean up controller code
  # http://ramblings.gibberishcode.net/archives/rails-has-and-belongs-to-many-habtm-demystified/17
  def update_budget_codings
    update_coding_attribute_proxy budget_codes_updates, :budget_codes
    update_coding_attribute_proxy budget_cost_categories_updates, :budget_cost_categories
    update_coding_attribute_proxy budget_district_codes_updates, :budget_district_codes
  end

  def update_expenditure_codings
    update_coding_attribute_proxy expenditure_codes_updates, :expenditure_codes
    update_coding_attribute_proxy expenditure_cost_categories_updates, :expenditure_cost_categories
    update_coding_attribute_proxy expenditure_district_codes_updates, :expenditure_district_codes
  end


  # assumes a format like "17,798,123.00"
  def currency_to_number(number_string, options ={})
    options.symbolize_keys!
    defaults  = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
    currency  = I18n.translate(:'number.currency.format', :locale => options[:locale], :raise => true) rescue {}
    defaults  = defaults.merge(currency)
    delimiter = options[:delimiter] || defaults[:delimiter]

    number_string.gsub(delimiter,'')
  end

end
