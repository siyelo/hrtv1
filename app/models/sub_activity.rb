
#require 'lib/ActAsDataElement' #super class already has it mixed in

class SubActivity < Activity
  belongs_to :activity
  attr_accessible :activity_id, :spend_percentage, :budget_percentage

end
