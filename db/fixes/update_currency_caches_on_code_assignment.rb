# before_save callback will update fields;
#   new_amount
#   new_cached_amount
#   new_cached_amount_in_usd
CodeAssignment.transaction do
  CodeAssignment.all.each do |ca|
    print "."
    ca.save(false)
  end
end