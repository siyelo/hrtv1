Factory.define :code_assignment, :class => CodeAssignment do |f|
  f.activity             { Factory.create :activity  }
  f.code                 { Factory.create :code }
  f.cached_amount        { 1000 }
  f.sum_of_children      { 0 } # db default value - used in specs
  f.cached_amount_in_usd { 0 } # db default value - used in specs
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

Factory.define :service_level_budget, :class => ServiceLevelBudget, :parent => :code_assignment do |f|
  f.code            { Factory.create :service_level }
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

Factory.define :service_level_spend, :class => ServiceLevelSpend, :parent => :code_assignment do |f|
  f.code            { Factory.create :service_level }
end
