
require 'lib/funding_flow_model_helper'
require 'lib/ActAsDataElement'

class FundingFlow < ActiveRecord::Base
  
  acts_as_commentable

  include ActAsDataElement
  configure_act_as_data_element

  before_save :authorize_and_set_owner

#  named_scope :available_to, lambda { |user|
#    {:conditions => ["organization_id_owner = ? or 1=?",
#      user.organization.id,
#      user.role?(:admin) ? 1 : 0 ]}
#  }
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
    "Flow: #{from.to_s} to #{to.to_s} for #{project.to_s}"
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
