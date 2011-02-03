#include MoneyHelper

def codings_sum(available_codes, activity, max, type, cache_object)
  total = 0
  max = 0 if max.nil?
  my_cached_amount = 0

  available_codes.each do |ac|
    ca = cache_object.get_code_assignment(type, activity.id, ac.id) # cached
    children = cache_object.get_children(ac) # cached
    if ca
      if ca.amount.present? && ca.amount > 0
        my_cached_amount = ca.amount
        sum_of_children = codings_sum(children, activity, max, type, cache_object)
        ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
      elsif ca.percentage.present? && ca.percentage > 0
        my_cached_amount = ca.percentage * max / 100
        sum_of_children = codings_sum(children, activity, max, type, cache_object)
        ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
      else
        sum_of_children = my_cached_amount = codings_sum(children, activity, max, type, cache_object)
        ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
      end
    else
      sum_of_children = my_cached_amount = codings_sum(children, activity, max, type, cache_object)
      CodeAssignment.create!(:activity => activity, :code => ac, :cached_amount => my_cached_amount) if sum_of_children > 0
    end
    total += my_cached_amount
  end
  total
end

cache_object = CacheObject.new

ca_types = [CodingBudget, CodingBudgetCostCategorization, CodingBudgetDistrict,
            CodingSpend, CodingSpendCostCategorization, CodingSpendDistrict]
#activities = Activity.find(:all, :conditions => ["id in (?)", [907, 909, 910, 911, 913]]) # DEBUG ONLY
activities = Activity.only_simple.all
total = activities.length
activities.each_with_index do |activity, index|
  puts "Updating activity id: #{activity.id}, :: #{index + 1}/#{total}"
  ca_types.each do |type|
    amount = codings_sum(type.available_codes(activity), activity, activity.max_for_coding(type), type, cache_object)
    activity.send("#{type}_amount=",  amount)
    activity.save(false) # save approved activities
    print "."
  end
end
puts "Activities cache update done..."

