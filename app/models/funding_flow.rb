
require 'lib/funding_flow_model_helper'
require 'lib/ActAsDataElement'

class FundingFlow < ActiveRecord::Base
  
  acts_as_commentable

  include ActAsDataElement
  configure_act_as_data_element

  before_save :authorize_and_set_owner

  default_scope :conditions => ["organization_id_owner = ?", ValueAtRuntime.new(Proc.new { User.organization.id}) ]

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
    # TODO authorize and throw exception if no create/update for you! no soup for you!

    # don't remove the self reference below! or it breaks

    #TODO current_user.organization
    self.owner = User.organization unless false #TODO current_user.admin?
  end
end
