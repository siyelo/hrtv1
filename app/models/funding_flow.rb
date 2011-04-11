require 'lib/ActAsDataElement'
require 'lib/BudgetSpendHelpers'
class FundingFlow < ActiveRecord::Base
  include ActAsDataElement
  include BudgetSpendHelpers

  configure_act_as_data_element

  ### Attributes
  attr_accessible :organization_text, :project_id, :data_response_id, :from, :to, 
                  :self_provider_flag, :organization_id_from, :organization_id_to,
                  :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4,
                  :budget, :budget_q4_prev, :budget_q1, :budget_q2, :budget_q3, :budget_q4

  ### Associations
  belongs_to :from, :class_name => "Organization", :foreign_key => "organization_id_from"
  belongs_to :to, :class_name => "Organization", :foreign_key => "organization_id_to"
  belongs_to :project
  belongs_to :data_response #TODO: deprecate in favour of: delegate :data_response, :to => :project

  ### Validations
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
end


# == Schema Information
#
# Table name: funding_flows
#
#  id                   :integer         primary key
#  organization_id_from :integer
#  organization_id_to   :integer
#  project_id           :integer         indexed
#  created_at           :timestamp
#  updated_at           :timestamp
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
#

