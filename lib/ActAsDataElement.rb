module ActAsDataElement
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    #include ApplicationHelper
    def configure_act_as_data_element
      include InstanceMethods
      has_one :data_element, :as => :data_elementable
      after_save :save_to_response
    end

  end

  module InstanceMethods
    include ApplicationHelper
    def save_to_response 
      #<TODO> find session with the response_id
      dr = User.current_user.current_data_response
      dr.add_or_update_element self
      dr.save
    end
  end
end
