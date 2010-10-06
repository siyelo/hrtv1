# == Schema Information
#
# Table name: data_requests
#
#  id                        :integer         not null, primary key
#  organization_id_requester :integer
#  title                     :string(255)
#  complete                  :boolean         default(FALSE)
#  pending_review            :boolean         default(FALSE)
#  created_at                :datetime
#  updated_at                :datetime
#

class DataRequest < ActiveRecord::Base
  attr_accessible :organization_id_requester, :title, :complete, :pending_review

  belongs_to :requesting_organization, :class_name => "Organization",
    :foreign_key => :organization_id_requester

  has_many :data_responses, :dependent => :destroy

  named_scope :fulfilling, lambda {|organization|
    return {} unless organization
    { :joins=>"INNER JOIN data_responses ON data_responses.data_request_id=data_requests.id", :conditions=>["data_responses.organization_id_responder=?", organization.id] }
  }
  named_scope :unfulfilled, lambda {|organization|
    return {} unless organization
    { :conditions=>[" id NOT IN ( SELECT data_request_id FROM data_responses WHERE data_responses.organization_id_responder = ? )", organization.id] }
  }

  def self.find_unfulfill_request organization_id
    DataRequest.find(:all, :conditions=>["organization_id_requester = ? AND complete = ?", organization_id, false])
  end

  def self.find_all_unfulfill_request
    DataRequest.find(:all, :conditions=>["complete = ?", false])
  end

  def add_data_element data
    data_element << data
  end

end
