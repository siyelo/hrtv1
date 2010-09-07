
def h(str)
  if str
    str.gsub!(',', '  ')
    str.gsub!("\n", '  ')
    str.gsub!("\t", '  ')
    str.gsub!("\015", "  ") # damn you ^M
  end
  str
end

locations = Location.find(:all, :select => 'short_display').map(&:short_display).sort
beneficiaries = Beneficiary.find(:all, :select => 'short_display').map(&:short_display).sort

#print header
str        = ''
str        = str + "org.name,"
str        = str + "org.type,"
str        = str + "a.name,"
str        = str + "a.description,"
beneficiaries.each do |ben|
  str      = str + "#{ben},"
end
str        = str + "a.text_for_beneficiaries,"
str        = str + "a.text_for_targets,"
str        = str + "a.target,"
str        = str + "a.budget,"
str        = str + "a.spend,"
str        = str + "a.provider,"
locations.each do |loc|
  str      = str + "#{loc},"
end
str = str + "project,"
puts str

#print data
Activity.all.each do |a|
  org = a.data_response.responding_organization
  str        = ''
  str        = str + "#{h org.name},"
  str        = str + "#{org.type},"
  str        = str + "#{h a.name},"
  str        = str + "#{h a.description},"
  act_benefs = a.beneficiaries.map(&:short_display)
  beneficiaries.each do |ben|
    str      = str + (act_benefs.include?(ben) ? "yes," : "," )
  end
  str        = str + "#{h a.text_for_beneficiaries},"
  str        = str + "#{h a.text_for_targets},"
  str        = str + "#{a.target},"
  str        = str + "#{a.budget},"
  str        = str + "#{a.spend},"
  str        = str + (a.provider.nil? ? "," : "#{h a.provider.name}," )
  act_locs   = a.locations.map(&:short_display)
  locations.each do |loc|
    str      = str + (act_locs.include?(loc) ? "yes," : "," )
  end

  #print out a row for each project
  if a.projects.empty?
    str = str + ","
    puts str
  else
    a.projects.each do |proj|
      proj_str = str + "#{h proj.name},"
      puts proj_str
    end
  end
end
