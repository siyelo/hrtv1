#require 'lib/ActAsDataElement'

class OtherCost < Activity
  # TODO create a set for each organization when a data request is created
  # from a list of examples (perhaps owned by the administrative organization)

  belongs_to :other_cost_type
  #include ActAsDataElement

  #configure_act_as_data_element

  
end
