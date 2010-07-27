class ExpenditureCoding < CodeAssignment
  validates_uniqueness_of :code_id, :scope => :activity_id
end