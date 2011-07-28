Factory.define :long_term_budget, :class => LongTermBudget do |f|
  f.organization_id { Factory(:organization) }
  f.year            { 2000 }
end
