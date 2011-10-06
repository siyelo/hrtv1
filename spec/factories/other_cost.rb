#
# Note: we dont yet define a Non-Project Other Cost. Simply create it by not
# passing project_id e.g.
#   oc = Factory(:other_cost_fully_coded, :data_response => @response)
#

Factory.define :other_cost_budget_spend_coded, :class => OtherCost, :parent => :activity do |f|
  f.coding_budget_district_valid  { true }
  f.coding_spend_district_valid   { true }
end

Factory.define :other_cost, :class => OtherCost, :parent => :activity do |f|
  f.sequence(:name) { |i| "other_cost_name_#{i}" }
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