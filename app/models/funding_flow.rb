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

#  named_scope :available_to, lambda { |user|
#    {:conditions => ["organization_id_owner = ? or 1=?",
#      user.organization.id,
#      user.role?(:admin) ? 1 : 0 ]}
#  }
  before_save :authorize_and_set_owner
  #TODO add current data response but since only 1 atm, dont need
  default_scope :conditions => ["organization_id_owner = ? or 1=?",
    ValueAtRuntime.new(Proc.new{User.current_user.organization.id}),
    ValueAtRuntime.new(Proc.new{User.current_user.role?(:admin) ? 1 : 0})]


  # donor enters/creates this
  # ngo enters/confirms with their amounts so can see any inconsistencies

  belongs_to :from, :class_name => "Organization", :foreign_key => "organization_id_from"
  belongs_to :to, :class_name => "Organization", :foreign_key => "organization_id_to"
  belongs_to :owner, :class_name => "Organization", :foreign_key => "organization_id_owner"

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
  protected

  def authorize_and_set_owner
    current_user = User.current_user
    # TODO authorize and throw exception if no create/update for you! no soup for you!

    # don't remove the self reference below, otherwise it breaks
    unless current_user.role?(:admin) && self.owner != nil
      self.owner = User.current_user.organization 
    end
  end

end
