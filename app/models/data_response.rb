# == Schema Information
#
# Table name: data_responses
#
#  id                        :integer         not null, primary key
#  data_element_id           :integer
#  data_request_id           :integer
#  complete                  :boolean         default(FALSE)
#  created_at                :datetime
#  updated_at                :datetime
#  organization_id_responder :integer
#  currency                  :string(255)
#  fiscal_year_start_date    :date
#  fiscal_year_end_date      :date
#

require 'lib/value_at_runtime'
class DataResponse < ActiveRecord::Base
  has_many :data_elements, :dependent=>:destroy
  has_many :users_currently_completing, :class_name => "User",
    :foreign_key => :data_response_id_current

  belongs_to :responding_organization, :class_name => "Organization",
    :foreign_key => "organization_id_responder"

  belongs_to :data_request

  default_scope :conditions => ["organization_id_responder = ? or 1=?",
    ValueAtRuntime.new(Proc.new{User.current_user.organization.id}),
    ValueAtRuntime.new(Proc.new{User.current_user.role?(:admin) ? 1 : 0})]

  def self.remove_security
    with_exclusive_scope {find(:all)}
  end

  named_scope :unfulfilled, :conditions => ["complete = ?", false]

  before_save :is_complete
 #after_save :all_responses_completed # TODO implement /fix, inf loops right now

  def add_or_update_element element_object
    # assumes raw object that has not been attached to an element
    # if it has been previously, then this does nothing
    # TODO raise exception if that's the case, i think?
    if element_object.data_element.nil? 
       data_elements.push(DataElement.create(:data_elementable => element_object))
       save
    end
  end

  def delete_element element_object
    unless element_object.data_element.nil?
      data_elements.delete(element_object.data_element)
    end
  end

  #TODO all of the code below is untested, do when 
  # we get to validations
  protected
  def all_responses_completed
    #check how many noncompleted response has not been fulfill it
    @noncompleted_responses_count = DataResponse.count(
      :conditions=>["complete = ? AND data_request_id = ?", 
        false, self.data_request_id])

    #check for first time datarequest creation
    if (@noncompleted_responses_count == 0) and (self.data_request.nil? == false)
      data_request.pending_review = true
      data_request.save
    end
  end

  def data_validated
    #TODO add more validation, right now only checks for 1 scenario
    complete != true && false
  end

  def is_complete
     complete = true if data_validated
  end
end
