class DataResponse < ActiveRecord::Base
  
  before_save :is_complete
  after_save :all_responses_completed
  has_many :data_elements

  belongs_to :data_request
  
  def self.unfulfilled 
    DataResponse.find(:all, :conditions => ["complete = ?", false])
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
