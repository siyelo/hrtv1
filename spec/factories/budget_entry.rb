Factory.define :budget_entry, :class => BudgetEntry do |f|
  f.long_term_budget_id { Factory(:long_term_budget) }
  f.purpose             { Factory(:mtef_code) }
  f.year                { 2000 }
  f.amount              { 10 }
end
