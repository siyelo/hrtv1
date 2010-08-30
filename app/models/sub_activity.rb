# == Schema Information
#
# Table name: activities
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  beneficiary            :string(255)
#  target                 :string(255)
#  created_at             :datetime
#  updated_at             :datetime
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
#  activity_id            :integer
#  budget_percentage      :decimal(, )
#  spend_percentage       :decimal(, )
#


#require 'lib/ActAsDataElement' #super class already has it mixed in

class SubActivity < Activity
  belongs_to :activity
  attr_accessible :activity_id, :spend_percentage, :budget_percentage

end
