require 'lib/value_at_runtime'
class DataResponse < ActiveRecord::Base
  
  before_save :is_complete
  after_save :all_responses_completed
  has_many :data_elements
  has_many :users_currently_completing, :class_name => "User",
    :foreign_key => :data_response_id_current

  belongs_to :responding_organization, :class_name => "Organization",
    :foreign_key => "organization_id_responder"

  belongs_to :data_request

  default_scope :conditions => ["organization_id_responder = ? or 1=?",
    ValueAtRuntime.new(Proc.new{User.current_user.organization.id}),
    ValueAtRuntime.new(Proc.new{User.current_user.role?(:admin) ? 1 : 0})]

  def self.unfulfilled 
    DataResponse.find(:all, :conditions => ["complete = ?", false])
  end

  def add_or_update_element element_object  #assumes raw object that has not been attached to an element

    if element_object.data_element.nil? 
       data_elements.push(DataElement.create(:data_elementable => element_object))
       save
    end
  end


  protected
  def all_responses_completed
     #check how many noncompleted response has not been fulfill it
       @noncompleted_responses_count = DataResponse.count(:conditions=>["complete = ? AND data_request_id = ?", false, self.data_request_id])
       if (@noncompleted_responses_count == 0) and (self.data_request.nil? == false)#check for first time datarequest creation
           data_request.pending_review = true
           data_request.save
       end
  end

  def data_validated
    #<TODO> add more validation, right now only checks for 1 scenario
    complete != true && false
  end

  def is_complete
     complete = true if data_validated
  end
end
