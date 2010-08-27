# == Schema Information
#
# Table name: activities
#
#  id                     :integer         primary key
#  name                   :string(255)
#  beneficiary            :string(255)
#  target                 :string(255)
#  created_at             :timestamp
#  updated_at             :timestamp
#  provider_id            :integer
#  other_cost_type_id     :integer
#  description            :text
#  type                   :string(255)
#  budget                 :decimal(, )
#  spend_q1               :decimal(, )
#  spend_q2               :decimal(, )
#  spend_q3               :decimal(, )
#  spend_q4               :decimal(, )
#  start                  :date
#  end                    :date
#  spend                  :decimal(, )
#  text_for_provider      :text
#  text_for_targets       :text
#  text_for_beneficiaries :text
#  spend_q4_prev          :decimal(, )
#  data_response_id       :integer
#



class OtherCost < Activity
  # TODO create a set for each organization when a data request is created
  # from a list of examples (perhaps owned by the administrative organization)

  def valid_roots_for_code_assignment
    @@valid_root_types = [ OtherCostCode ] #TODO change to right types
    Code.roots.reject { |r| ! @@valid_root_types.include? r.class }
    #TODO add code so that non-root notes can start the top of the tree
  end

  def self.valid_types_for_code_assignment
    [OtherCostCode]
  end

   # GR - this needs refactoring in
  #belongs_to :other_cost_type

   # this not so much
  #VALID_ROOT_TYPES = %w[ Nha ]
end
