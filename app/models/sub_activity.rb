
#require 'lib/ActAsDataElement' #super class already has it mixed in

class SubActivity < Activity
  belongs_to :activity

end
