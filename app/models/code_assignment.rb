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
  belongs_to :activity
  belongs_to :code

  validates_presence_of :activity, :code

  attr_accessible :activity, :code, :amount, :percentage

end
