# == Schema Information
#
# Table name: activities
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  beneficiary        :string(255)
#  target             :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  comments           :string(255)
#  expected_total     :decimal(, )
#  provider_id        :integer
#  other_cost_type_id :integer
#  description        :text
#  type               :string(255)
#  start_month        :string(255)
#  end_month          :string(255)
#  budget             :decimal(, )
#  spend_q1           :decimal(, )
#  spend_q2           :decimal(, )
#  spend_q3           :decimal(, )
#  spend_q4           :decimal(, )
#

class OtherCost < Activity
  # TODO create a set for each organization when a data request is created
  # from a list of examples (perhaps owned by the administrative organization)

  belongs_to :other_cost_type

  VALID_ROOT_TYPES = %w[Nha]

end
