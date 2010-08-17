# == Schema Information
#
# Table name: organizations
#
#  id         :integer         primary key
#  name       :string(255)
#  type       :string(255)
#  created_at :timestamp
#  updated_at :timestamp
#  raw_type   :string(255)
#


class Organization < ActiveRecord::Base
  attr_accessible :name

  acts_as_commentable

  has_many :users # people in this organization
  has_and_belongs_to_many :activities # activities that target / aid this org

  has_many :data_requests_made, :class_name => "DataRequest",
    :foreign_key => :organization_id_requester

  has_many :data_responses, :foreign_key => :organization_id_responder

  has_many :out_flows, :class_name => "FundingFlow", :foreign_key => "organization_id_from"
  has_many :in_flows, :class_name => "FundingFlow", :foreign_key => "organization_id_to"

  has_many :donor_for, :through => :out_flows, :source => :project
  has_many :implementor_for, :through => :in_flows, :source => :project
  has_many :provider_for, :class_name => "Activity", :foreign_key => :provider_id

  #has_many :funding_flows #TODO should be named like owned_funding_flows
  # for some reason the association above was giving AS problems... when i trie dto implement the subforms

  has_and_belongs_to_many :locations

  def self.remove_security
    with_exclusive_scope {find(:all)}
  end
  # this was buggy and really doesn't represent what we want
  # a person should create a data request for a list of orgs
  # right now, only 1 data request we create manually thats why there's no ui
#  after_save :create_data_responses
#
#  def create_data_responses
#    if data_responses.empty?
#      DataRequest.all.each do |d|
#        d.data_responses.build :responding_organization => self
#      end
#    end
#  end

  def to_s
    name
  end

  def self.providers_for locations
    orgs=Organization.find_by_sql( ["
      SELECT o.id
      FROM organizations o, locations_organizations l
      WHERE o.id=l.organization_id
      AND l.location_id in (?)",
      locations.collect {|l| l.id} ])
  end
end
