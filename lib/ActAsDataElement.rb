module ActAsDataElement
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    #include ApplicationHelper
    def configure_act_as_data_element
      include InstanceMethods
      belongs_to :data_response
      named_scope :available_to, lambda { |current_user|
        if current_user.role?(:admin)
          {}
        else
          {:conditions=>{:data_response_id => current_user.current_data_response.id}}
        end
      }
    end
  end

  module InstanceMethods
  end
end
