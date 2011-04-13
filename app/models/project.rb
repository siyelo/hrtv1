require 'lib/acts_as_stripper' #TODO move
require 'lib/ActAsDataElement'
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

  cattr_reader :per_page
  @@per_page = 3

  acts_as_stripper
  acts_as_commentable

  ### Associations
  belongs_to :data_response, :counter_cache => true
  has_and_belongs_to_many :locations
  has_many :activities, :dependent => :destroy
  has_many :other_costs, :dependent => :destroy
  has_many :normal_activities, :class_name => "Activity",
           :conditions => [ "activities.type IS NULL"], :dependent => :destroy
  has_many :funding_flows, :dependent => :destroy
  has_many :in_flows, :class_name => "FundingFlow",
           :conditions => [ 'self_provider_flag = 0 AND
                            organization_id_to = #{organization.id}' ] #note the single quotes !
  has_many :out_flows, :class_name => "FundingFlow",
           :conditions => [ 'self_provider_flag = 0 AND
                            organization_id_from = #{organization.id}' ] #note the single quotes !
  has_many :funding_sources, :through => :funding_flows, :class_name => "Organization",
            :source => :from, :conditions => "funding_flows.self_provider_flag = 0"
  has_many :providers, :through => :funding_flows, :class_name => "Organization",
           :source => :to

  # Nested attributes
  accepts_nested_attributes_for :funding_flows, :allow_destroy => true
  before_validation_on_create :assign_project_to_funding_flows

  ### Named scopes
  named_scope :available_to, lambda { |current_user|
    if current_user.admin?
      {}
    else
      {:conditions=>{:data_response_id => current_user.current_data_response.try(:id)}}
    end
  }

  ### Validations
  validates_uniqueness_of :name, :scope => :data_response_id
  validates_presence_of :name, :data_response_id
  validates_numericality_of :spend, :if => Proc.new {|model| !model.spend.blank?}
  validates_numericality_of :budget, :if => Proc.new {|model| !model.budget.blank?}
  validates_numericality_of :entire_budget, :if => Proc.new {|model| !model.entire_budget.blank?}
  validates_date :start_date
  validates_date :end_date
  validates_dates_order :start_date, :end_date, :message => "Start date must come before End date."
  validate :validate_budgets, :if => Proc.new { |model| model.budget.present? && model.entire_budget.present? }
 
  ### Attributes
  attr_accessible :name, :description, :spend,
                  :start_date, :end_date, :currency, :data_response, :activities,
                  :location_ids, :funding_flows_attributes, :budget, :entire_budget,
                  :budget_q1, :budget_q2, :budget_q3, :budget_q4, :budget_q4_prev,
                  :spend_q1, :spend_q4_prev, :spend_q2, :spend_q3, :spend_q4

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

  # if these are needed to fix saving, then they are missing
  # in activity
  # if not, then they are superfluous
  def spend=(amount)
    super(strip_non_decimal(amount))
  end

  def budget=(amount)
    super(strip_non_decimal(amount))
  end

  def entire_budget=(amount)
    super(strip_non_decimal(amount))
  end

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
    trace_ultimate_funding_source(organization, funders, [organization])
  end

  private

    def validate_budgets
      #TODO FY is explicitly ref'd, should come from data request
      errors.add(:base, "Total Budget must be less than or equal to Total Budget FY 10-11") if budget > entire_budget
    end

    def trace_ultimate_funding_source(organization, funders, traced = [])
      funding_sources = []

      funders.each do |funder|

        funder_reported_flows = funder.in_flows.select{|f| f.organization == funder}
        # check if org in any of funders self-reported projects
        # if so, only traverse up / consider flows in those projects
        #if implementer_in_flows?(organization, funder_reported_flows)
          self_flows = funder_reported_flows.select{|f| f.from == funder}
          parent_flows = funder_reported_flows.select{|f| f.from != funder}
       # else
       #   self_flows = funder.in_flows.select{|f| f.from == funder}
       #   parent_flows = funder.in_flows.select{|f| f.from != funder}
       # end

        # real UFS - self funded organization that funds other organizations
        # i.e. has activity(ies) with the organization as implementer
        if implementer_in_flows?(organization, self_flows)
          funding_sources << funder
        end

        # potential UFS - parent funded organization that funds other organizations
        # i.e. does not have any activity(ies) with organization as implementer
        unless implementer_in_flows?(organization, parent_flows)
          self_funded = funder.in_flows.map(&:from).include?(funder)

          if self_funded
            funding_sources << funder
          elsif funder.in_flows.empty? # when funder has blank data response
            funding_sources << funder
          end
        end

        # keep looking in parent funders
        unless traced.include?(funder)
          traced << funder
          parent_funders = parent_flows.map(&:from).reject{|f| f.nil?}
          funding_sources.concat(trace_ultimate_funding_source(funder, parent_funders, traced))
        end
      end

      funding_sources.uniq
    end

    def implementer_in_flows?(organization, flows)
      flows.map(&:project).reject{|f| f.nil?}.map(&:activities).flatten.
        map(&:provider).include?(organization)
    end

    # GN: Do we need to remove this or it has no side effects?
    # Definitely enable assign_project_to_funding_flows when finishing PT: 12144777

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

