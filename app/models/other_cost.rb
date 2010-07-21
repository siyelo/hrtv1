class OtherCost < Activity
  # TODO create a set for each organization when a data request is created
  # from a list of examples (perhaps owned by the administrative organization)

  belongs_to :other_cost_type
  has_many :data_elements, :as => :data_elementable
end
