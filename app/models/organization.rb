class Organization < ActiveRecord::Base
  attr_accessible :name

  acts_as_commentable
  has_many :out_flows, :class_name => "FundingFlow", :foreign_key => "organization_id_from" 
  has_many :in_flows, :class_name => "FundingFlow", :foreign_key => "organization_id_to" 

  has_many :donor_for, :through => :out_flows, :source => :project
  has_many :implementor_for, :through => :in_flows, :source => :project
end
