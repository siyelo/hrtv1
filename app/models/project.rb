require 'lib/acts_as_stripper' #TODO move
require 'lib/BudgetSpendHelpers'
require 'validators'

class Project < ActiveRecord::Base
  ### Constants
  FILE_UPLOAD_COLUMNS = %w[name description currency entire_budget
                         budget budget_q4_prev budget_q1 budget_q2 budget_q3
                         budget_q4 spend spend_q4_prev spend_q1 spend_q2
                         spend_q3 spend_q4 start_date end_date]

  include ActsAsDateChecker
  include CurrencyCacheHelpers
  include BudgetSpendHelpers
  include NumberHelper

  cattr_reader :per_page
  @@per_page = 3

  acts_as_stripper
  strip_commas_from_all_numbers

  ### Associations
  belongs_to :data_response, :counter_cache => true
  has_and_belongs_to_many :locations
  has_many :activities, :dependent => :destroy
  has_many :other_costs, :dependent => :destroy
  has_many :normal_activities, :class_name => "Activity",
           :conditions => [ "activities.type IS NULL"], :dependent => :destroy
  has_many :funding_flows, :dependent => :destroy
  has_many :funding_streams, :dependent => :destroy
  has_many :in_flows, :class_name => "FundingFlow",
           :conditions => [ 'self_provider_flag = 0 and
                            organization_id_to = #{organization.id}' ] #note the single quotes !
  has_many :out_flows, :class_name => "FundingFlow",
           :conditions => [ 'self_provider_flag = 0 AND
                            organization_id_from = #{organization.id}' ] #note the single quotes !
  has_many :funding_sources, :through => :funding_flows, :class_name => "Organization",
            :source => :from, :conditions => "funding_flows.self_provider_flag = 0"
  has_many :providers, :through => :funding_flows, :class_name => "Organization",
           :source => :to
  has_many :comments, :as => :commentable, :dependent => :destroy

  # Nested attributes
  accepts_nested_attributes_for :in_flows, :allow_destroy => true
  before_validation_on_create :assign_project_to_funding_flows

  ### Validations
  validates_uniqueness_of :name, :scope => :data_response_id
  validates_presence_of :name, :data_response_id
  validates_numericality_of :spend, :if => Proc.new {|model| model.spend.present?} 
  validates_numericality_of :budget, :if => Proc.new {|model| model.budget.present?}
  validates_numericality_of :entire_budget, :if => Proc.new {|model| !model.entire_budget.blank?}
  validates_date :start_date
  validates_date :end_date
  validates_dates_order :start_date, :end_date, :message => "Start date must come before End date."
  validate :validate_total_budget_not_exceeded, :if => Proc.new { |model| model.budget.present? && model.entire_budget.present? }
  validate :validate_budgets, :if => Proc.new { |model| model.budget.present? && model.entire_budget.present? }

  ### Attributes
  attr_accessible :name, :description, :spend,
                  :start_date, :end_date, :currency, :data_response, :activities,
                  :location_ids, :in_flows_attributes, :budget, :entire_budget,
                  :budget_q1, :budget_q2, :budget_q3, :budget_q4, :budget_q4_prev,
                  :spend_q1, :spend_q4_prev, :spend_q2, :spend_q3, :spend_q4,
                  :budget2, :budget3, :budget4, :budget5

  # Delegates
  # TODO pull all this DR related stuff to module and mix in
  delegate :organization, :to => :data_response

  ### Callbacks
  after_save :update_cached_currency_amounts
  
  ### Public methods
  #
  def implementers
    providers
  end

  def response
    self.data_response
  end

  # view helper ??!
  def organization_name
    organization.name
  end

  # Returns DR.currency if no project currency specified
  def currency
    c = read_attribute(:currency)
    return c if new_record?
    return c unless c.blank?
    return data_response.currency
  end
  
  
  #Methods correctly strip the non-word characters from the following fields
  CURRENCY_FIELDS = [:budget, :budget_q1, :budget_q2, :budget_q3, :budget_q4, :spend, :spend_q1, :spend_q2, :spend_q3, :spend_q4,  :entire_budget]
    Project.class_eval CURRENCY_FIELDS.each.inject("") {|s,field| s += <<END}
      def #{field}=(amount)
        super(strip_non_decimal(amount))
      end
END
#do not indent the above end

  def to_s
    result = ''
    result = name unless name.nil?
    result
  end

  # TODO... GR: this is view code - must be moved out of the model
  def to_label #so text doesn't spill over in nested scaffs.
      to_s
  end

  def deep_clone
    clone = self.clone
    # HABTM's
    %w[locations].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc))
    end

    # has_many's with deep associations
    %w[activities].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc).collect { |obj| obj.deep_clone })
    end

    # shallow has_many's
    %w[funding_flows].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc).collect { |obj| obj.clone })
    end
    clone
  end

  def self.download_template
    FasterCSV.generate do |csv|
      csv << Project::FILE_UPLOAD_COLUMNS
    end
  end

  def self.create_from_file(doc, data_response)
    saved, errors = 0, 0
    doc.each do |row|
      attributes = row.to_hash
      project = data_response.projects.new(attributes)
      project.save ? (saved += 1) : (errors += 1)
    end
    return saved, errors
  end

  def ultimate_funding_sources
    funders = in_flows.map(&:from).reject{|f| f.nil?}
    trace_ultimate_funding_source(organization, funders.uniq)
  end

  def cached_ultimate_funding_sources
    ufs = []
    funding_streams.each do |fs|
      ufs << {:ufs => fs.ufs, :fa => fs.fa, :budget => budget, :spend => spend}
    end

    ufs
  end

  def spend_entered?
    spend.present? || spend_q1.present? || spend_q2.present? || 
      spend_q3.present? || spend_q4.present? || spend_q4_prev.present?
  end

  def budget_entered?
    budget.present? || budget_q1.present? || budget_q2.present? || 
      budget_q3.present? || budget_q4.present? || budget_q4_prev.present?
  end

  def linked?
    return false if self.in_flows.empty?
    self.in_flows.each do |in_flow|
      return false unless in_flow.project_from_id
    end
    true
  end
   
  def has_activities?
    !self.normal_activities.empty?
  end
  
  def has_other_costs?
    !self.activities.with_type("OtherCost").empty?
  end

  def budget_matches_funders?
     self.in_flows.empty? || (self.budget == self.in_flows_budget_total)
  end
  
  def in_flows_budget_total
    return 0 if self.funding_sources.empty?
    in_flows.reject{|fs| fs.budget.nil?}.sum(&:budget)
  end

  def spend_matches_funders?
    self.spend == self.in_flows_spend_total 
  end
  
  def in_flows_spend_total
    in_flows.reject{|fs| fs.spend.nil?}.sum(&:spend)
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

  private
  
    ### Validations
    
    def validate_total_budget_not_exceeded
      errors.add(:base, "Budget must be less than or equal to the Total Budget") if budget > entire_budget
    end
    
    ### Misc
    
    def trace_ultimate_funding_source(organization, funders, traced = [])
      #spacing = '   ' * traced.length                 # DEBUG
      #puts "#{spacing}tracing #{organization.name}"   # DEBUG
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
            elsif funder.in_flows.empty? || funder.raw_type == "Donor" # when funder has blank data response
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
        unless (funder.raw_type == "Donor" && !activities_funders.include?(parent_funder))
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
      scope = scope.scoped(:conditions => ["organization_id_from = ?
                                            AND organization_id_to = ?",
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

    # work arround for validates_presence_of :project issue
    # children relation can do only validation by :project, not :project_id
    # See: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2815-nested-models-build-should-directly-assign-the-parent
    def assign_project_to_funding_flows
      funding_flows.each {|ff| ff.project = self}
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
#  budget           :decimal(, )
#  spend            :decimal(, )
#  entire_budget    :decimal(, )
#  currency         :string(255)
#  spend_q1         :decimal(, )
#  spend_q2         :decimal(, )
#  spend_q3         :decimal(, )
#  spend_q4         :decimal(, )
#  spend_q4_prev    :decimal(, )
#  data_response_id :integer         indexed
#  budget_q1        :decimal(, )
#  budget_q2        :decimal(, )
#  budget_q3        :decimal(, )
#  budget_q4        :decimal(, )
#  budget_q4_prev   :decimal(, )
#  comments_count   :integer         default(0)
#  budget2          :decimal(, )
#  budget3          :decimal(, )
#  budget4          :decimal(, )
#  budget5          :decimal(, )
#

