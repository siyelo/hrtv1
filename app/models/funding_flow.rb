require 'lib/BudgetSpendHelpers'
class FundingFlow < ActiveRecord::Base
  include BudgetSpendHelpers

  ### Attributes
  attr_accessible :organization_text, :project_id, :data_response_id, :from, :to,
                  :self_provider_flag, :organization_id_from, :organization_id_to,
                  :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4,
                  :budget, :budget_q4_prev, :budget_q1, :budget_q2, :budget_q3, :budget_q4

  ### Associations
  belongs_to :from, :class_name => "Organization", :foreign_key => "organization_id_from"
  belongs_to :to, :class_name => "Organization", :foreign_key => "organization_id_to"
  belongs_to :project
  belongs_to :project_from # funder's project
  belongs_to :data_response # TODO: deprecate in favour of: delegate :data_response, :to => :project

  alias :response :data_response
  alias :response= :data_response=

  ### Validations

  # if project from id == nil => then the user hasnt linked them
  # if project from id == 0 => then the user can't find Funder project in a list
  # if project from id > 0 => user has selected a Funder project
  validates_numericality_of :project_from_id, :greater_than_or_equal_to => 0,
    :unless => lambda {|fs| fs["project_from_id"].blank? }

  # GN: Removed until UI shows these well
  # PT: 12144777
  #validates_presence_of :project
  #validates_presence_of :data_response_id
  #validates_presence_of :organization_id_from, :organization_id_to

  delegate :organization, :to => :project

  def currency
    project.try(:currency)
  end

  def name
    "From: #{from.name} - To: #{to.name}"
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

  def funding_chains
    if self_funded? or donor_funded? or candidates_empty?
      { :org_chain => [from, to], :ufs => from, :fa => to,
        :budget => budget, :spend => spend}
    else
      # without a linked project, need some heuristic logic
      # to figure out which projects from the from organization
      # to get the ultimate funding sources from
      chains = find_fuzzy_linked_projects
      chains.each do |c|
        c[:fa] = c[:org_chain].last # the funding agent is always the penultimate org
        c[:org_chain] << to  # add our org to the end of the chain to show entire flow
      end
      adjust_to_total(chains, budget, :budget)
      adjust_to_total(chains, spend, :spend)

      chains
    end
  end

  def find_fuzzy_linked_projects
    if project_from #if the project is linked to funders project
      chains = project_from.ultimate_funding_sources
    else
      # find all possible projects we may have been funded by
      candidates = candidate_projects

      # adjust so the funding chain total matches our activity total
      chains = to_provider_totals(candidates).map do |t|
        adjust_to_total(t.ultimate_funding_sources, t[:budget], :budget)
        adjust_to_total(t.ultimate_funding_sources, t[:spend], :spend)
      end

      # if no activites found for us in our funders projects
      # then take all of our funders' funding sources
      if chains.nil? or chains.size == 0
        chains = candidates.map(&:ultimate_funding_sources)
      end
    end
    chains.flatten
  end

  # look in the activities, total all amounts where we were a provider
  def to_provider_totals(candidates)
    total = candidates.collect do |p|
      b_total = p.activities.inject(0){|a,sum| sum += a.amount_for_provider(to, :budget)}
      s_total = p.activities.inject(0){|a,sum| sum += a.amount_for_provider(to, :spend)}
      if b_total > 0 or s_total > 0
        {:p => p, :budget => b_total, :spend => s_total}
      else
        []
      end
    end
    total.reject{|r| r==[]}
  end

  def self_funded?
    from == to
  end

  def donor_funded?
    ["Donor",  "Multilateral", "Bilateral"].include?(from.raw_type)
  end

  def candidate_projects
    # find all possible projects we may have been funded by
    candidates = from.projects.select do |p|
      p.response.data_request == self.response.data_request
    end
  end

  def candidates_empty?
    candidate_projects.empty?
  end

  # helper
  def adjust_to_total(collection, target_total, amount_key)
    collection = collection.dup
    collection_total = collection.sum{|e| e[amount_key]}
    collection.each do |e|
      e[amount_key] = (e[amount_key] * target_total) / collection_total
    end
    collection
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
#  data_response_id     :integer         indexed
#  budget_q1            :decimal(, )
#  budget_q2            :decimal(, )
#  budget_q3            :decimal(, )
#  budget_q4            :decimal(, )
#  budget_q4_prev       :decimal(, )
#  comments_count       :integer         default(0)
#  project_from_id      :integer
#

