class BudgetCoding < CodeAssignment
  validates_uniqueness_of :code_id, :scope => :activity_id

end