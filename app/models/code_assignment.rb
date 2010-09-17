# == Schema Information
#
# Table name: code_assignments
#
#  id          :integer         not null, primary key
#  activity_id :integer
#  code_id     :integer
#  code_type   :string(255)
#  amount      :decimal(, )
#  type        :string(255)
#  percentage  :decimal(, )
#

class CodeAssignment < ActiveRecord::Base

  # Associations
  belongs_to :activity
  belongs_to :code

  # Validations
  validates_presence_of :activity, :code

  # Attributes
  attr_accessible :activity, :code, :amount, :percentage

  # Named scopes
  named_scope :with_code_ids, lambda {|code_ids| {:conditions => ["code_assignments.code_id IN (?)", code_ids]} }
end
