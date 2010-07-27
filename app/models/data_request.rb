class DataRequest < ActiveRecord::Base
  attr_accessible :organization_id_requester, :title, :complete, :pending_review

  belongs_to :requesting_organization, :class_name => "Organization",
    :foreign_key => :organization_id_requester

  has_many :data_responses

  def self.find_unfulfill_request organization_id
    DataRequest.find(:all, :conditions=>["organization_id_requester = ? AND complete = ?", organization_id, false])
  end
  def self.find_all_unfulfill_request
    DataRequest.find(:all, :conditions=>["complete = ?", false])
  end

  after_save :check_response_created

  def add_data_element data
    data_element << data
  end

  protected
  def check_response_created
    if data_responses.empty?
      Organization.all.each do |org|
        data_responses.create :responding_organization => org
      end
    end
  end

end
