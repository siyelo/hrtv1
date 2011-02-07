include MoneyHelper

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

#[Activity.find(1974)].each_with_index do |a, index|
Activity.all.each_with_index do |a, index|
  puts "Updating activity id: #{a.id}, counter: #{index}"
  if [OtherCost, Activity].include?(a.class)
    [CodingBudget, CodingBudgetCostCategorization, CodingBudgetDistrict,
     CodingSpend, CodingSpendCostCategorization, CodingSpendDistrict].each do |type|
      coding_tree = CodingTree.new(a, type)
      amount = codings_sum(coding_tree.available_codes, a, a.max_for_coding(type), type, cache_object)
      a.send("#{type}_amount=",  amount)

      a.save(false) # save approved activities
    end
  end
end
