short_display_to_correct_external_id = {
9020101040101	=> "Prevention for Youth in School",
9020101040102	=> "Prevention Programs for Youth out of School",
9020101040103	=> "Prevention Programs for MSM",
9020101040104	=> "Prevention Programs for IDUs",
9020101040105	=> "Workplace Prevention Programs",
9020101040106	=> "1.04 Risk-reduction for vulnerable and accessible populations",
9020101040107	=> "Community Mobilzation",
9020101070101	=> "Female Condom Distribution and Provision",
9020101070102	=> "Condom Provision in Public and Commercial Sector",
9020101070103	=> "Social Marketing of Condoms",
}

if Code.all(:conditions => {:external_id => "9.0201E+12"}).size != short_display_to_correct_external_id.size
  puts "error - mismatch in number of codes being corrected"
else
	short_display_to_correct_external_id.each do |external_id, short_display|
	  c = Code.find_by_short_display short_display
	  puts c.external_id
	  c.external_id = external_id
	  c.save
	end
end

# one off for one without description

