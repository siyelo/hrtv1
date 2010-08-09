# == Schema Information
#
# Table name: funding_flows
#
#  id                    :integer         not null, primary key
#  organization_id_from  :integer
#  organization_id_to    :integer
#  project_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  budget                :decimal(, )
#  spend_q1              :decimal(, )
#  spend_q2              :decimal(, )
#  spend_q3              :decimal(, )
#  spend_q4              :decimal(, )
#  organization_id_owner :integer
#  organization_text     :text
#  self_provider_flag    :integer         default(0)
#  spend                 :decimal(, )
#  spend_q4_prev         :decimal(, )
#

require 'lib/value_at_runtime'
require 'lib/ActAsDataElement'

# == Schema Information
#
# Table name: funding_flows
#
#  id                    :integer         not null, primary key
#  organization_id_from  :integer
#  organization_id_to    :integer
#  project_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  raw_provider          :text
#  budget                :decimal(, )
#  spend_q1              :decimal(, )
#  spend_q2              :decimal(, )
#  spend_q3              :decimal(, )
#  spend_q4              :decimal(, )
#  organization_id_owner :integer
#
class FundingFlow < ActiveRecord::Base
  
  acts_as_commentable

  include ActAsDataElement
  configure_act_as_data_element

  # donor enters/creates this
  # ngo enters/confirms with their amounts so can see any inconsistencies

  belongs_to :from, :class_name => "Organization", :foreign_key => "organization_id_from"
  belongs_to :to, :class_name => "Organization", :foreign_key => "organization_id_to"

  belongs_to :project

  def to_s
    "Flow"#: #{from.to_s} to #{to.to_s} for #{project.to_s}"
    # TODO replace when fix text flying over action links
    # in nested scaffolds
  end

  # had to add this in to solve some odd AS bug...
  def to_label
    to_s
  end
end
