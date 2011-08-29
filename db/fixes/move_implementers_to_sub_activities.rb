# usage:  move_implementers.rb <where clause>
#
# E.g.  move_implementers.rb "activities.id < 1000"
#       move_implementers.rb "activities.id >= 1000 AND activities.id < 2000"
#       move_implementers.rb "activities.id > 2000"
#

ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

Activity.after_save.reject! {|callback| callback.method.to_s == 'update_counter_cache'}
Activity.after_destroy.reject! {|callback| callback.method.to_s == 'update_counter_cache'}

puts " => finding activities where #{ARGV.first}"

activities = Activity.only_simple.find(:all, :conditions => ARGV.first, :order => "activities.id")
total = activities.count
activities.each_with_index do |a, index|
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
    print "\n"
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

puts "  => done"