Activity.only_simple.each do |a|
  puts ""
  puts "Migrating Activity: Id: #{a.id}, Name: #{a.name}"
  sab_total = a.sub_activities.reject{|sa| sa.budget.nil?}.sum(&:budget)
  sae_total = a.sub_activities.reject{|sa| sa.spend.nil?}.sum(&:spend)
  spends_match = (a.spend == sae_total)
  budgets_match =  (sab_total == a.budget)
  puts "Before"
  puts "  => a.spend: #{a.spend}, sub_activity.total_spend: #{sae_total}"
  puts "  => a.budget: #{a.budget}, sub_activity.total_budget: #{sab_total}"
  im = ImplementerMover.new(a, true)
  im.move!
  a.reload
  sab_total = a.sub_activities.reject{|sa| sa.budget.nil?}.sum(&:budget)
  sae_total = a.sub_activities.reject{|sa| sa.spend.nil?}.sum(&:spend)
  spends_match = (a.spend == sae_total)
  budgets_match =  (sab_total == a.budget)
  puts "After"
  puts "  => a.spend: #{a.spend}, sub_activity.total_spend: #{sae_total}"
  puts "  => a.budget: #{a.budget}, sub_activity.total_budget: #{sab_total}"
end