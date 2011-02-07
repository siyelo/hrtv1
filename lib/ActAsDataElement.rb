module ActAsDataElement
  def self.included(base)
    base.extend(ClassMethods)
  end


  #TODO GN refactor and pull counter caching back in from
  # models like project
  module ClassMethods
    #include ApplicationHelper
    def configure_act_as_data_element
      include InstanceMethods

      belongs_to :data_response

      attr_accessible :data_response

      has_one :owner, :through => :data_response, :source => :organization

      named_scope :available_to, lambda { |current_user|
        if current_user.role?(:admin)
          {}
        else
          {:conditions=>{:data_response_id =>
                            current_user.current_data_response.try(:id)}}
        end
      }
    end
  end

  module InstanceMethods
  end
end
