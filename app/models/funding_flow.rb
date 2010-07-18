class FundingFlow < ActiveRecord::Base
  acts_as_commentable

  default_scope :conditions => {:organization_id_from =>  ValueAtRuntime.new(Proc.new { User.organization.id}) } 
  
  # donor enters/creates this
  # ngo enters/confirms with their amounts so can see any inconsistencies

  belongs_to :from, :class_name => "Organization", :foreign_key => "organization_id_from"
  belongs_to :to, :class_name => "Organization", :foreign_key => "organization_id_to"
  #belongs_to :owner, :class_name => "Organization", :foreign_key => "organization_id_owner"

  belongs_to :project

  def to_s
    "Flow: #{from.to_s} to #{to.to_s} for #{project.to_s}"
  end
end
