duplicate_code = Code.find(:first, :conditions => {:short_display => 'Subsidisation Of Health Services and Performance Incentives'})
duplicate_code.delete
correct_code = Code.find(:first, :conditions => {:short_display => 'Subsidisation Of Health Services'})
correct_code.short_display = 'Subsidisation Of Health Services and Performance Incentives'
correct_code.save!
