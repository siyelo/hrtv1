Factory.define :code_assignment, :class => CodeAssignment do |f|
  f.activity        { Factory.create :activity  }
  f.code            { Factory.create :code }
  f.amount          { 1000 }
end

Factory.define :coding_budget, :class => CodingBudget, :parent => :code_assignment do |f|
  f.code            { Factory.create :mtef_code }
end

Factory.define :coding_budget_district, :class => CodingBudgetDistrict, :parent => :code_assignment do |f|
  f.code            { Factory.create :mtef_code }
end

Factory.define :coding_budget_cost_categorization, :class => CodingBudgetCostCategorization, :parent => :code_assignment do |f|
  f.code            { Factory.create :mtef_code }
end

Factory.define :coding_spend, :class => CodingSpend, :parent => :code_assignment do |f|
  f.code            { Factory.create :mtef_code }
end

Factory.define :coding_spend_district, :class => CodingSpendDistrict, :parent => :code_assignment do |f|
  f.code            { Factory.create :mtef_code }
end

Factory.define :coding_spend_cost_categorization, :class => CodingSpendCostCategorization, :parent => :code_assignment do |f|
  f.code            { Factory.create :mtef_code }
end
