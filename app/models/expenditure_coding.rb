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
#

class ExpenditureCoding < CodeAssignment
  validates_uniqueness_of :code_id, :scope => :activity_id
end
