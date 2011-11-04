require 'validators'

class Project < ActiveRecord::Base
  include ActsAsDateChecker
  include BudgetSpendHelper
  include Project::Validations
  include ResponseStateCallbacks

  MAX_NAME_LENGTH = 64

  strip_commas_from_all_numbers

  ### Associations
  belongs_to :data_response, :counter_cache => true
  belongs_to :user
  has_one :organization, :through => :data_response
  has_many :activities, :dependent => :destroy
  has_many :other_costs, :dependent => :destroy
  has_many :normal_activities, :class_name => "Activity",
           :conditions => [ "activities.type IS NULL"], :dependent => :destroy
  has_many :funding_flows, :dependent => :destroy

  #FIXME - cant initialize nested in_flows because of the :conditions statement
  has_many :in_flows, :class_name => "FundingFlow"
  has_many :out_flows, :class_name => "FundingFlow",
           :conditions => [ 'organization_id_from = #{organization.id}' ]
  has_many :comments, :as => :commentable, :dependent => :destroy

  # Nested attributes
  accepts_nested_attributes_for :in_flows, :allow_destroy => true,
    :reject_if => Proc.new { |attrs| attrs['organization_id_from'].blank? }
  accepts_nested_attributes_for :activities

  ### Callbacks
  # also check lib/response_state_callbacks
  before_validation :assign_project_to_in_flows
  before_validation :assign_project_to_activities
  before_validation :strip_leading_spaces
  after_save        :update_activity_amount_cache
  after_save        :update_cached_currency_amounts,
    :if => Proc.new { |p| p.currency_changed? }


  ### Validations
  # also see validations in BudgetSpendHelper
  validates_uniqueness_of :name, :scope => :data_response_id
  validates_presence_of :name, :data_response_id
  validates_inclusion_of :currency,
    :in => Money::Currency::TABLE.map{|k, v| "#{k.to_s.upcase}"},
    :allow_nil => true, :unless => Proc.new {|p| p.currency.blank?}
  validates_date :start_date
  validates_date :end_date
  validates_dates_order :start_date, :end_date,
    :message => "Start date must come before End date."
  validates_length_of :name, :within => 1..MAX_NAME_LENGTH

  validate :has_in_flows?, :if => Proc.new {|model| model.in_flows.reject{ |attrs|
    attrs['organization_id_from'].blank? || attrs.marked_for_destruction? }.empty?}

  validate :validate_funder_uniqueness

  ### Attributes
  attr_accessible :name, :description, :spend, :user_id,:data_response_id,
                  :start_date, :end_date, :currency, :data_response, :activities,
                  :activities_attributes, :in_flows_attributes, :am_approved,
                  :am_approved_date, :in_flows

  ### Delegates
  delegate :organization, :to => :data_response, :allow_nil => true #workaround for object creation

  ### Named Scopes
  named_scope :sorted, { :order => "projects.name" }


  ### Instance methods
  #
  def response
    data_response
  end

  # view helper ??!
  def organization_name
    organization.name
  end

  # TODO: spec
  def budget
    activities.only_simple.map{ |a| a.budget || 0 }.sum
  end

  # TODO: spec
  def spend
    activities.only_simple.map{ |a| a.spend || 0 }.sum
  end

  # Returns DR.currency if no project currency specified
  def currency
    c = read_attribute(:currency)
    return c unless c.blank?
    return data_response.currency
  end

  def to_s
    result = ''
    result = name unless name.nil?
    result
  end

  def deep_clone
    clone = self.clone
    # HABTM's
    %w[user].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc))
    end

    # has_many's with deep associations
    [:normal_activities, :other_costs].each do |assoc|
      clone.send(assoc) << self.send(assoc).map { |obj| obj.deep_clone }
    end

    clone.in_flows = self.in_flows.collect { |obj| obj.project_id = nil; obj.clone }

    clone
  end

  def amount_for_provider(provider, field)
    activities.inject(0) do |sum, a|
      amt = a.amount_for_provider(provider, field)
      sum += amt unless amt.nil?
      sum = sum
    end
  end

  def funding_sources_have_organizations_and_amounts?
    in_flows.all? { |ff| ff.has_organization_and_amounts? }
  end

  def has_activities?
    !normal_activities.empty?
  end

  def has_other_costs?
    !activities.with_type("OtherCost").empty?
  end

  # calculates the activity totals for budget/spent
  # FIXME - unclear if this returns ALL NORMAL ACTIVITIES + OTHER COSTS + SUB ACTIVITIES???!
  def subtotals(type)
    activities.select{|a| a.send(type).present?}.sum(&type)
  end

  def in_flows_total(amount_method)
    smart_sum(in_flows, amount_method)
  end

  def activities_budget_total
    activities.roots.reject{|fs| fs.budget.nil?}.sum(&:budget)
  end

  def other_costs_budget_total
    other_costs.reject{|fs| fs.budget.nil?}.sum(&:budget)
  end

  def activities_spend_total
    activities.roots.reject{|fs| fs.spend.nil?}.sum(&:spend)
  end

  def other_costs_spend_total
    other_costs.reject{|fs| fs.spend.nil?}.sum(&:spend)
  end

  def direct_activities_total(amount_type)
    smart_sum(activities.roots, amount_type)
  end

  def other_costs_total(amount_type)
    smart_sum(other_costs, amount_type)
  end

  def locations
    activities.only_simple.inject([]){ |acc, a| acc.concat(a.locations) }.uniq
  end

  def update_cached_currency_amounts
    self.activities.each do |a|
      a.code_assignments.each {|c| c.save}
      a.save
    end

    self.in_flows.each do |in_flow|
      in_flow.save unless in_flow.marked_for_destruction?
    end
  end

  private

    def has_in_flows?
      errors.add_to_base "Project must have at least one Funding Source."
    end

    def implementer_in_flows?(organization, flows)
      flows.map(&:project).reject{|f| f.nil?}.map(&:activities).flatten.
        map(&:provider).include?(organization)
    end

    def strip_leading_spaces
      self.name = self.name.strip if self.name
      self.description = self.description.strip if self.description
    end

    def update_activity_amount_cache
      activities.each { |a| a.send(:update_cached_usd_amounts) } if currency_changed?
    end

    # work arround for validates_presence_of :project issue
    # children relation can do only validation by :project, not :project_id
    # See: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2815-nested-models-build-should-directly-assign-the-parent
    def assign_project_to_in_flows
      in_flows.each {|ff| ff.project = self}
    end

    #assign project object so nested attributes for activities pass the project_id validation
    def assign_project_to_activities
      activities.each {|a| a.project = self}
    end

    def validate_funder_uniqueness
      funders = in_flows.select{|e| !e.marked_for_destruction? }.map(&:organization_id_from)
      if funders.length != funders.uniq.length
        errors.add_to_base "Duplicate Project Funding Sources"
      end
    end
end


# == Schema Information
#
# Table name: projects
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  description      :text
#  start_date       :date
#  end_date         :date
#  created_at       :datetime
#  updated_at       :datetime
#  currency         :string(255)
#  data_response_id :integer         indexed
#

