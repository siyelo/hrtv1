require 'validators'

class Project < ActiveRecord::Base
  include ActsAsDateChecker
  include BudgetSpendHelper
  include NumberHelper
  include Project::Validations

  MAX_NAME_LENGTH = 64

  strip_commas_from_all_numbers

  ### Associations
  belongs_to :data_response
  belongs_to :user
  has_one :organization, :through => :data_response
  has_many :activities, :dependent => :destroy
  has_many :other_costs, :dependent => :destroy
  has_many :normal_activities, :class_name => "Activity",
           :conditions => [ "activities.type IS NULL"], :dependent => :destroy
  has_many :funding_flows, :dependent => :destroy
  has_many :funding_streams, :dependent => :destroy

  #FIXME - cant initialize nested in_flows because of the :conditions statement
  has_many :in_flows, :class_name => "FundingFlow"
  has_many :out_flows, :class_name => "FundingFlow",
           :conditions => [ 'organization_id_from = #{organization.id}' ]
  has_many :providers, :through => :funding_flows, :class_name => "Organization",
           :source => :to
  has_many :comments, :as => :commentable, :dependent => :destroy

  # Nested attributes
  accepts_nested_attributes_for :in_flows, :allow_destroy => true,
    :reject_if => Proc.new { |attrs| attrs['organization_id_from'].blank? }
  accepts_nested_attributes_for :activities

  ### Callbacks
  before_validation :assign_project_to_in_flows
  before_validation :assign_project_to_activities
  before_validation :strip_leading_spaces
  after_save :update_activity_amount_cache

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
                  :am_approved_date, :in_flows, :updated_at

  ### Delegates
  delegate :organization, :to => :data_response, :allow_nil => true #workaround for object creation

  ### Callbacks
  after_save   :update_cached_currency_amounts, :if => Proc.new { |p| p.currency_changed? }
  after_create :start_response_if_unstarted
  after_destroy :unstart_response_if_all_projects_removed

  ### Named Scopes
  named_scope :sorted, { :order => "projects.name" }

  ### Instance methods
  #
  def implementers
    providers
  end

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
    return "USD" if data_response.nil?
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

    # shallow has_many's
    %w[in_flows funding_streams].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc).collect { |obj| obj.project_id = nil; obj.clone })
    end
    clone
  end

  def amount_for_provider(provider, field)
    activities.inject(0) do |sum, a|
      amt = a.amount_for_provider(provider, field)
      sum += amt unless amt.nil?
      sum = sum
    end
  end

  def funding_chains(fake_if_none = true, scale_if_not_match_proj = true)
    ufs = in_flows.map(&:funding_chains).flatten
    ufs = FundingChain.merge_chains(ufs)
    if ufs.empty? and fake_if_none
      # if data bad, assume self-funded
      ufs = [FundingChain.new({:organization_chain => [organization, organization],
       :budget => budget, :spend => spend})]
    end
    if scale_if_not_match_proj
      ufs = FundingChain.adjust_amount_totals!(ufs, spend, budget)
    end
    ufs
  end

  def ultimate_funding_sources
    funding_chains
  end

  def funding_chains_to(to)
      s = amount_for_provider(to, :spend)
      b = amount_for_provider(to, :budget)
      fs = funding_chains
      if s > 0 or b > 0
        FundingChain.add_to(fs, to, s, b)
      else
        []
      end
  end

  def cached_ultimate_funding_sources
    ufs = []
    funding_streams.each do |fs|
      # fa = financing agent - the last link in the chain before the actual implementer
      ufs << {:ufs => fs.ufs, :fa => fs.fa, :budget => fs.budget, :spend => fs.spend}
    end
    ufs
  end

  def funding_sources_have_organizations?
    in_flows.each do |in_flow|
      return false unless in_flow.organization_id_from
    end
    true
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
      in_flow.save
    end
  end

  private

    def has_in_flows?
      errors.add_to_base "Project must have at least one Funding Source."
    end

    def trace_ultimate_funding_source(organization, funders, traced = [])
      traced = traced.dup
      traced << organization
      funding_sources = []

      funders.each do |funder|

        funder_reported_flows = funder.in_flows.select{|f| f.organization == funder}
        self_flows = funder_reported_flows.select{|f| f.from == funder}
        parent_flows = funder_reported_flows.select{|f| f.from != funder}

        # real UFS - self funded organization that funds other organizations
        # i.e. has activity(ies) with the organization as implementer
        if implementer_in_flows?(organization, self_flows)
          ffs = organization.in_flows.select{|ff| ff.from == funder}

          funding_sources << {:ufs => funder, :fa => traced.last,
                              :budget => get_budget(ffs), :spend => get_spend(ffs)}
        else
          # potential UFS - parent funded organization that funds other organizations
          # i.e. does not have any activity(ies) with organization as implementer
          unless implementer_in_flows?(organization, parent_flows)
            self_funded = funder.in_flows.map(&:from).include?(funder)

            if self_funded
              ffs = funder.in_flows.select{|ff| ff.from == funder}
              funding_sources << {:ufs => funder, :fa => traced.last,
                                  :budget => get_budget(ffs), :spend => get_spend(ffs)}
            elsif funder.in_flows.empty? || ["Multilateral", "Bilateral", "Donor"].include?(funder.raw_type) || funder.name == "Ministry of Health" # when funder has blank data response
              budget, spend = get_budget_and_spend(funder.id, organization.id)
              funding_sources << {:ufs => funder, :fa => traced.last,
                                  :budget => budget, :spend => spend}
            end
          end
        end


        # keep looking in parent funders
        unless traced.include?(funder)
          parent_funders = parent_flows.map(&:from).reject{|f| f.nil?}
          parent_funders = remove_not_funded_donors(funder, parent_funders)
          funding_sources.concat(trace_ultimate_funding_source(funder, parent_funders.uniq, traced))
        end
      end

      funding_sources
    end

    # TODO: optimize this method
    def remove_not_funded_donors(funder, parent_funders)
      activities = funder.projects.map(&:activities).flatten.compact
      activities_funders = activities.map(&:project).
        map(&:in_flows).flatten.map(&:from).flatten.reject{|p| p.nil?}

      real_funders = []

      parent_funders.each do |parent_funder|
        unless ((funder.raw_type == "Donor" || funder.name == "Ministry of Health") &&
                !activities_funders.include?(parent_funder))
          real_funders << parent_funder
        end
      end

      real_funders
    end

    def implementer_in_flows?(organization, flows)
      flows.map(&:project).reject{|f| f.nil?}.map(&:activities).flatten.
        map(&:provider).include?(organization)
    end

    def get_budget_and_spend(from_id, to_id, project_id = nil)
      scope = FundingFlow.scoped({})
      # TODO - refactor SQL. we need to add Org Id on project...
      scope = scope.scoped(:conditions => ["organization_id_from = ?
                                            AND project_id IN (
                                              SELECT id FROM projects
                                              where data_response_id in (
                                                SELECT id FROM data_responses
                                                 WHERE organization_id = ?))",
                                            from_id, to_id])
      scope = scope.scoped(:conditions => {:project_id => project_id}) if project_id
      ffs = scope.all

      [get_budget(ffs), get_spend(ffs)]
    end

    def get_budget(funding_sources)
      amount = 0
      funding_sources.group_by { |ff| ff.project }.each do |project, fss|
        budget = fss.reject{|ff| ff.budget.nil?}.sum(&:budget)
        amount += budget * currency_rate(project.currency, 'USD')
      end
      amount
    end

    def get_spend(funding_sources)
      amount = 0
      funding_sources.group_by { |ff| ff.project }.each do |project, fss|
        spend = fss.reject{|ff| ff.spend.nil?}.sum(&:spend)
        amount += spend * currency_rate(project.currency, 'USD')
      end
      amount
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

    def start_response_if_unstarted
      response.start! if response.unstarted?
    end

    def unstart_response_if_all_projects_removed
      response.unstart! if response.projects.empty?
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
#  comments_count   :integer         default(0)
#

