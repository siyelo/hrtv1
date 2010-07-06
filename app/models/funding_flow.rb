class FundingFlow < ActiveRecord::Base
  acts_as_commentable
  # donor enters/creates this
  # ngo enters/confirms with their amounts so can see any inconsistencies

  belongs_to :from, :class_name => "Organization", :foreign_key => "organization_id_from"
  belongs_to :to, :class_name => "Organization", :foreign_key => "organization_id_to"

  belongs_to :project

  def to_s
    "Flow: #{from.to_s} to #{to.to_s} for #{project.to_s}"
  end
end
