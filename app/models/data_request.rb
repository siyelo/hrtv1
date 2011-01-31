class DataRequest < ActiveRecord::Base
  attr_accessible :organization_id_requester, :title, :complete, :pending_review

  belongs_to :requesting_organization, :class_name => "Organization",
    :foreign_key => :organization_id_requester

  has_many :data_responses, :dependent => :destroy

  validates_presence_of :requesting_organization
  validates_presence_of :title

  named_scope :unfulfilled, lambda {|organization|
    return {} unless organization
    { :conditions=>[" id NOT IN ( SELECT data_request_id FROM data_responses WHERE data_responses.organization_id_responder = ? )", organization.id] }
  }

  def self.find_unfulfill_request organization_id
    DataRequest.find(:all, :conditions=>["organization_id_requester = ? AND complete = ?", organization_id, false])
  end

  def self.find_all_unfulfill_request
    DataRequest.find(:all, :conditions => ["complete = ?", false])
  end
end

# == Schema Information
#
# Table name: data_requests
#
#  id                        :integer         primary key
#  organization_id_requester :integer
#  title                     :string(255)
#  complete                  :boolean         default(FALSE)
#  pending_review            :boolean         default(FALSE)
#  created_at                :timestamp
#  updated_at                :timestamp
#

