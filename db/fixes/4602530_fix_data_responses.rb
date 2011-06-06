
d = DataResponse.find(6088) ; #a random, good DR
corrupt_orgs = []
Organization.all.each { |o| corrupt_orgs << o if o.data_responses.empty? }
puts corrupt_orgs
puts corrupt_orgs.count
corrupt_orgs.each { |o| new_dr = d.clone; new_dr.organization_id = o.id; new_dr.save!; }

after_fix_orgs = []
Organization.all.each { |o| after_fix_orgs << o if o.data_responses.empty? }
puts after_fix_orgs.count
