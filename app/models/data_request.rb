class DataRequest < ActiveRecord::Base

  attr_accessible :organization_id, :title, :complete, :pending_review, :due_date

  ### Associations
  belongs_to :organization
  has_many :data_responses, :dependent => :destroy

  ### Validations
  validates_presence_of :organization_id
  validates_presence_of :title
  validates_presence_of :due_date

  ### Named scopes
  # TODO: spec
  named_scope :unfulfilled, lambda {|organization|
    return {} unless organization
    { :conditions=>[" id NOT IN ( SELECT data_request_id FROM data_responses WHERE data_responses.organization_id = ? )", organization.id] }
  }

  # TODO: spec
  def self.find_unfulfill_request(organization_id)
    DataRequest.find(:all, :conditions=>["organization_id= ? AND complete = ?", organization_id, false])
  end

  # TODO: spec
  def self.find_all_unfulfill_request
    DataRequest.find(:all, :conditions => ["complete = ?", false])
  end

end

# == Schema Information
#
# Table name: data_requests
#
#  id              :integer         not null, primary key
#  organization_id :integer
#  title           :string(255)
#  complete        :boolean         default(FALSE)
#  pending_review  :boolean         default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

