#require 'lib/ActAsDataElement'

class OtherCost < Activity
  # TODO create a set for each organization when a data request is created
  # from a list of examples (perhaps owned by the administrative organization)

  belongs_to :other_cost_type
<<<<<<< HEAD

  def valid_roots_for_code_assignment
    @@valid_root_types = [ Nha] #TODO change to right types
    Code.roots.reject { |r| ! @@valid_root_types.include? r.class }
    #TODO add code so that non-root notes can start the top of the tree
  end
=======
  #include ActAsDataElement

  #configure_act_as_data_element

  
>>>>>>> 8759c7302f088bab26a59ee7174b861470f2ece6
end
