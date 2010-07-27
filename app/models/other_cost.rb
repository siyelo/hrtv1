class OtherCost < Activity
  # TODO create a set for each organization when a data request is created
  # from a list of examples (perhaps owned by the administrative organization)

  belongs_to :other_cost_type

  @@valid_root_types = [ Nha] #TODO change to right types
  def valid_roots_for_code_assignment
    @@valid_root_types = [ Nha] #TODO change to right types
    Code.roots.reject { |r| ! @@valid_root_types.include? r.class }
    #TODO add code so that non-root notes can start the top of the tree
  end
end
