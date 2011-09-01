duplicate_code = Code.find(:first, :conditions => {:short_display => 'Subsidisation Of Health Services and Performance Incentives'})
if duplicate_code
  duplicate_code.delete
end

correct_code = Code.find(:first, :conditions => {:short_display => 'Subsidisation Of Health Services'})
if correct_code
  correct_code.short_display = 'Subsidisation Of Health Services and Performance Incentives'
  correct_code.save!
end
