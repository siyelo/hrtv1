require 'lib/ActAsDataElement'
require 'lib/BudgetSpendHelpers'
class FundingFlow < ActiveRecord::Base
  include ActAsDataElement
  include BudgetSpendHelpers

  configure_act_as_data_element
  acts_as_commentable

  ### Attributes
  attr_accessible :budget, :organization_text, :project, :data_response_id,
                  :from, :to, :self_provider_flag, :spend, :spend_q4_prev,
                  :spend_q1, :spend_q2, :spend_q3, :spend_q4,
                  :organization_id_from, :organization_id_to

  ### Associations
  belongs_to :from, :class_name => "Organization", :foreign_key => "organization_id_from"
  belongs_to :to, :class_name => "Organization", :foreign_key => "organization_id_to"
  belongs_to :project
  belongs_to :data_response #TODO: deprecate in favour of: delegate :data_response, :to => :project

  ### Validations
  #GN: validations break how users create a new org if that org not in the list
  # sadly they are disabled for now
  validates_presence_of :project_id#, :organization_id_from, :organization_id_to
  validates_presence_of :data_response_id # required for AS/available_to magickery
                                          # consider removing relation and delegating to project

  delegate :organization, :to => :project
  delegate :data_response, :to => :project

  # Named scopes
  # TODO: spec
  named_scope :with_organizations, :conditions => "organization_id_from IS NOT NULL AND organization_id_to IS NOT NULL"

  def to_s
    "Flow"
  end

  # had to add this in to solve some odd AS bug...
  # TODO: remove
  def to_label
    to_s
  end

  ## TODO: remove
  def name
    from.name
  end

  # TODO: spec
  def currency
    project.try(:currency)
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
#

