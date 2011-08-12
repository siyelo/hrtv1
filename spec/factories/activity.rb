Factory.define :activity, :class => Activity do |f|
  f.sequence(:name) { |i| "activity_name_#{i}_#{rand(100_000_000)}" }
  f.description     { 'activity_description' }
  f.budget          { 50.00 }
  f.spend           { 40.00 }
  f.start_date      { "2010-01-01" }
  f.end_date        { "2010-12-31" }
end

Factory.define :other_cost, :class => OtherCost, :parent => :activity do |f|
  f.sequence(:name) { |i| "other_cost_name_#{i}" }
end

Factory.define :sub_activity, :class => SubActivity, :parent => :activity do |f|
  f.sequence(:name) { |i| "sub_activity_name_#{i}" }
  f.description     { 'sub_activity_description' }
  f.provider        { Factory.create(:provider) }
end


### Partial factories: just to keep it DRY
Factory.define :_budget_coded, :class => Activity, :parent => :activity  do |f|
  f.coding_budget_valid           { true }
  f.coding_budget_cc_valid        { true }
  f.coding_budget_district_valid  { true }
  f.coding_spend_valid            { true }
  f.coding_spend_cc_valid         { true }
  f.coding_spend_district_valid   { true }
  f.after_create { |a| Factory(:coding_budget_district, :cached_amount => 50, :activity => a) }
  f.after_create { |a| Factory(:coding_budget_cost_categorization, :cached_amount => 50, :activity => a) }
end

Factory.define :_spend_coded, :class => Activity, :parent => :activity  do |f|
  f.coding_budget_valid           { true }
  f.coding_budget_cc_valid        { true }
  f.coding_budget_district_valid  { true }
  f.coding_spend_valid            { true }
  f.coding_spend_cc_valid         { true }
  f.coding_spend_district_valid   { true }
  f.after_create { |a| Factory(:coding_spend_district, :cached_amount => 40, :activity => a) }
  f.after_create { |a| Factory(:coding_spend_cost_categorization, :cached_amount => 40, :activity => a) }
end
# end partials


### Factories with codings

Factory.define :activity_w_spend_coding, :class => Activity, :parent => :_spend_coded  do |f|
  f.coding_budget_valid           { true }
  f.coding_budget_cc_valid        { true }
  f.coding_budget_district_valid  { true }
  f.coding_spend_valid            { true }
  f.coding_spend_cc_valid         { true }
  f.coding_spend_district_valid   { true }
  f.after_create { |a| Factory(:coding_spend, :cached_amount => 40, :activity => a) }
end

Factory.define :activity_w_budget_coding, :class => Activity, :parent => :_budget_coded  do |f|
  f.after_create { |a| Factory(:coding_budget, :cached_amount => 50, :activity => a) }
end

Factory.define :activity_fully_coded, :class => Activity, :parent => :activity_w_spend_coding  do |f|
  # Not DRY. Need to figure out how to mix two factories together
  f.after_create { |a| Factory(:coding_budget, :cached_amount => 50, :activity => a) }
  f.after_create { |a| Factory(:coding_budget_district, :cached_amount => 50, :activity => a) }
  f.after_create { |a| Factory(:coding_budget_cost_categorization, :cached_amount => 50, :activity => a) }
end

Factory.define :other_cost_w_spend_coding, :class => OtherCost, :parent => :_spend_coded  do |f|
  f.coding_budget_valid           { true }
  f.coding_budget_cc_valid        { true }
  f.coding_budget_district_valid  { true }
  f.coding_spend_valid            { true }
  f.coding_spend_cc_valid         { true }
  f.coding_spend_district_valid   { true }
  f.after_create { |a| Factory(:coding_spend_other_cost, :cached_amount => 40, :activity => a) }
end

Factory.define :other_cost_w_budget_coding, :class => OtherCost, :parent => :_budget_coded  do |f|
  f.after_create { |a| Factory(:coding_budget_other_cost, :cached_amount => 50, :activity => a) }
end

Factory.define :other_cost_fully_coded, :class => OtherCost, :parent => :other_cost_w_spend_coding  do |f|
  # Not DRY. Need to figure out how to mix two factories together
  f.after_create { |a| Factory(:coding_budget_other_cost, :cached_amount => 50, :activity => a) }
  f.after_create { |a| Factory(:coding_budget_district, :cached_amount => 50, :activity => a) }
  f.after_create { |a| Factory(:coding_budget_cost_categorization, :cached_amount => 50, :activity => a) }
end
