class FundingFlow < ActiveRecord::Base
  include BudgetSpendHelper
  include GorAmountHelpers

  HUMANIZED_ATTRIBUTES = {
    :organization_id_from => "The Funding Source 'from' organization",
    :organization_id_to => "The Funding Source 'to' organization",
    :budget => "The Funding Source budget",
    :spend => "The Funding Source spend" }

  ### Attributes
  attr_accessible :organization_text, :project_id, :from, :to,
                  :self_provider_flag, :organization_id_from, :organization_id_to,
                  :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4,
                  :budget, :budget_q4_prev, :budget_q1, :budget_q2, :budget_q3,
                  :budget_q4, :updated_at

  ### Associations
  belongs_to :from, :class_name => "Organization", :foreign_key => "organization_id_from"
  belongs_to :to, :class_name => "Organization", :foreign_key => "organization_id_to"
  belongs_to :project
  belongs_to :project_from # funder's project

  ### Validations
  # also see validations in BudgetSpendHelper
  # validates_presence_of :project # FIXME
  validates_presence_of :organization_id_from
  validates_presence_of :organization_id_to

  # if project from id == nil => then the user hasnt linked them
  # if project from id == 0 => then the user can't find Funder project in a list
  # if project from id > 0 => user has selected a Funder project
  #
  validates_numericality_of :project_from_id, :greater_than_or_equal_to => 0, :unless => lambda {|fs| fs["project_from_id"].blank?}
  # if we pass "-1" then the user somehow selected "Add an Organization..."
  validates_numericality_of :organization_id_from, :greater_than_or_equal_to => 0,
    :unless => lambda {|fs| fs["project_from_id"].blank?}

  ### Callbacks
  # also see callbacks in BudgetSpendHelper

  ### Delegates
  delegate :organization, :to => :project
  delegate :data_response, :to => :project
  delegate :currency, :to => :project

  alias :response :data_response

  ### Class Methods

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def self.create_flows(params)
    unless params[:funding_flows].blank?
      params[:funding_flows].each_pair do |flow_id, project_id|
        ff = self.find(flow_id)
        ff.project_from_id = project_id
        ff.save
      end
    end
  end

  ### Instance Methods

  def name
    "From: #{from.name} - To: #{to.name}"
  end

  def updated_at
    Time.now
  end

  def funding_chains
    if self_funded?
      [FundingChain.new({ :organization_chain => [from, to],
                          :budget => budget, :spend => spend })]
    else
      chains = from.best_guess_funding_chains_to(to, response.data_request) unless from.nil?

      unless chains.nil? or chains.empty?
        # TODO for better heurestics will need to pass
        # amounts up into best_guess_funding_chains_to
        FundingChain.adjust_amount_totals!(chains,
      spend.try(:>, 0) ?  spend : 0,
          budget.try(:>, 0) ? budget : 0)

        chains
      else
        error = from.nil? ? "From was nil" : "From guessed no chains"
        puts error
        # raise error
        [FundingChain.new(
          {:organization_chain => [Organization.new(:name => "Unspecified"), to],
           :budget => budget, :spend => spend})]
      end

    end
  end

  def self_funded?
    from == to
  end

  def donor_funded?
    ["Donor",  "Multilateral", "Bilateral"].include?(from.raw_type)
  end

  private
    def spend_is_greater_than_zero
      errors.add(:spend, "for funding must be greater than 0") unless (spend || 0) > 0
    end
end






# == Schema Information
#
# Table name: funding_flows
#
#  id                   :integer         not null, primary key
#  organization_id_from :integer
#  organization_id_to   :integer
#  project_id           :integer         indexed
#  created_at           :datetime
#  updated_at           :datetime
#  budget               :decimal(, )
#  spend_q1             :decimal(, )
#  spend_q2             :decimal(, )
#  spend_q3             :decimal(, )
#  spend_q4             :decimal(, )
#  organization_text    :text
#  self_provider_flag   :integer         default(0), indexed
#  spend                :decimal(, )
#  spend_q4_prev        :decimal(, )
#  budget_q1            :decimal(, )
#  budget_q2            :decimal(, )
#  budget_q3            :decimal(, )
#  budget_q4            :decimal(, )
#  budget_q4_prev       :decimal(, )
#  project_from_id      :integer
#  budget_in_usd        :decimal(, )     default(0.0)
#  spend_in_usd         :decimal(, )     default(0.0)
#

