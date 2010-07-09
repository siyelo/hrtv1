class CodeAssignment < ActiveRecord::Base

  belongs_to :activity
  belongs_to :code, :polymorphic => true

  validates_presence_of :activity, :code
  validates_uniqueness_of :code_id, :scope => :activity_id

end
