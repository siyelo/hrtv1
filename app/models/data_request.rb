class DataRequest < ActiveRecord::Base

  before_save :check_response_created
  belongs_to :requesting_organization, :class_name => "Organization",
    :foreign_key => :organization_id_requester

  has_many :data_responses

  def self.find_unfulfill_request organization_id
    DataRequest.find(:all, :conditions=>["organization_id = ? AND complete = ?", organization_id, false])
  end
  def self.find_all_unfulfill_request
    DataRequest.find(:all, :conditions=>["complete = ?", false])
  end

  def add_data_element data
    data_element << data
  end

  protected
  def check_response_created
    if data_responses.empty? 
      data_responses << DataResponse.create
    end
  end
	
end
