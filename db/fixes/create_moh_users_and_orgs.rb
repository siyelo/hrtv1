["claudinion@gmail.com", "mukwesij@yahoo.fr", "josemashav@yahoo.fr ", "kayigery@yahoo.fr ", "maniraguharuth@yahoo.fr ", "mbajean@yahoo.fr", "mat_mic2001@yahoo.fr", "watuma2001@yahoo.fr"].each do |email|   u=User.find_by_email(email);    puts "#{u.organization} - #{email}" if u; puts email if !u; puts u.current_response.activities.size if u.current_response; end



h={"claudinion@gmail.com" => "Temp-Unit Not Specified", "mukwesij@yahoo.fr" => "COMMUNITY HEALTH/MOH", "josemashav@yahoo.fr" => "CTAMS -THE TECHNICAL SUPPORT CELL TO HEALTH SCHEMES (MUTUELLES DE SANTE)/MOH", "kayigery@yahoo.fr" => "MCH (MATERNAL AND CHILD HEALTH)/MOH", "maniraguharuth@yahoo.fr" => "Psychosocial Consultation Centre (SCPS)/MOH", "mbajean@yahoo.fr" => "MCH (MATERNAL AND CHILD HEALTH)/MOH", "mat_mic2001@yahoo.fr" => "CAAC(THE CONTRACTUAL APPROACH SUPPORT CELL)/MOH", "watuma2001@yahoo.fr" => "SAMU-EMERGENCY MEDICAL ASSISTANCE SERVICE/MOH "}
h.each do |email,org_text|  u=User.find_or_create_by_email(email);   o=Organization.find_or_create_by_name(org_text);   u.organization = o;   o.data_responses.create(:data_request => DataRequest.first) if o.data_responses.size == 0;   u.password = "password"; u.password_confirmation = "password";   u.current_response = u.organization.data_responses.first;   puts u.save; end

 h.each do |email, org|  u=User.find_by_email email;   puts "#{u} #{email}";   puts "#{email} #{u.organization} #{u.organization.data_responses.size}";   end
