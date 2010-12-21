
Activity.transaction do
  Activity.all.each do |a|
    print "."
    a.save(false) #callback will update new_budget/spend(_in_usd) fields
  end
end