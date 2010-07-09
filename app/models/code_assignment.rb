class CodeAssignment < ActiveRecord::Base
  acts_as_commentable
  belongs_to :activity
  belongs_to :code, :polymorphic => true

end
