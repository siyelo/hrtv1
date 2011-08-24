
total = Activity.only_simple.count

Activity.after_save.reject! {|callback| callback.method.to_s == 'update_counter_cache'}
Activity.after_destroy.reject! {|callback| callback.method.to_s == 'update_counter_cache'}

Activity.only_simple.sorted_by_id.each_with_index do |a, index|
  print "  => #{index} of #{total}; id: #{a.id}"
  #puts "Migrating Activity: Id: #{a.id}, Name: #{a.name}"
  # sab_total = a.sub_activities.reject{|sa| sa.budget.nil?}.sum(&:budget)
  # sae_total = a.sub_activities.reject{|sa| sa.spend.nil?}.sum(&:spend)
  # spends_match = (a.spend == sae_total)
  # budgets_match =  (sab_total == a.budget)
  # puts "Before"
  # puts "  => a.spend: #{a.spend}, sub_activity.total_spend: #{sae_total}"
  # puts "  => a.budget: #{a.budget}, sub_activity.total_budget: #{sab_total}"
  im = ImplementerMover.new(a, true)
  im.move!
  #a.reload
  # sab_total = a.sub_activities.reject{|sa| sa.budget.nil?}.sum(&:budget)
  # sae_total = a.sub_activities.reject{|sa| sa.spend.nil?}.sum(&:spend)
  # spends_match = (a.spend == sae_total)
  # budgets_match =  (sab_total == a.budget)
  # puts "After"
  # puts "  => a.spend: #{a.spend}, sub_activity.total_spend: #{sae_total}"
  # puts "  => a.budget: #{a.budget}, sub_activity.total_budget: #{sab_total}"
end

Activity.send :after_save, :update_counter_cache #re-enable callback
Activity.send :after_destroy, :update_counter_cache #re-enable callback
