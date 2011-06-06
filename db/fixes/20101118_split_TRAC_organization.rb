def clone_to_new(from_org, name)
  target = from_org.clone
  target.name = name
  target.save!
  puts "  cloned a new organization: #{target.name} (from #{from_org.name})"
  target
end


def move_users(from_org, to_org, emails, dr)
  emails.each do |e|
    users = User.find_all_by_email(e)
    raise "no user email" unless users
    raise "more than one email found for this user" if users.size > 1
    user = users.first
    raise "user is not part of source org" unless user.organization == from_org
    user.organization = to_org
    user.current_data_response = dr
    user.save!
    puts "  moved user: #{e}"
  end
end


### create 2 extra orgs
#
original_trac = Organization.find 3054

#
### TRAC - Malaria
#
puts "Creating TRAC+ - Malaria..."
Organization.transaction do
  trac_malaria = clone_to_new(original_trac, "TRAC+ - Malaria")
  original_dr = original_trac.data_responses.first
  new_dr = DataResponse.new(:data_request => original_dr.data_request,
                        :organization => trac_malaria)

  existing_user_emails = ["joseph.baguma@gmail.com"]
  move_users(original_trac, trac_malaria, existing_user_emails, new_dr)
  trac_malaria.reload

  # move projects
  projects = [original_dr.projects.find_by_name("TREATMENT : DIAGNOSIS"),
              original_dr.projects.find_by_name("Training, Seminars and Workshops"),
              original_dr.projects.find(508),
              original_dr.projects.find_by_name("Monitoring and Evaluation"),
              original_dr.projects.find_by_name("LLIN Distribution"),
              original_dr.projects.find_by_name("Insecticide monitoring"),
              original_dr.projects.find_by_name("Human Resource"),
              original_dr.projects.find_by_name("FIGHT AGAINST MALARIA"),
              original_dr.projects.find_by_name("Community outreach"),
              original_dr.projects.find_by_name("Community interventions"),
              original_dr.projects.find_by_name("BCC MASS MEDIA"),
              original_dr.projects.find(382) ]
  raise "project snap!" unless projects.size == 12

  projects.each do |p|
    p.data_response = new_dr

    p.activities.each do |a|
      a.data_response = new_dr
      a.save!
    end
    # Note: you may need to move sub activities !!
    p.save(false)
  end
  new_dr.reload
  raise  "  project counts dont match!" unless new_dr.projects.size == 12

  original_trac.in_flows.each do |f|
    f.to = trac_malaria
    f.data_response = new_dr
    f.save(false)
  end
  trac_malaria.reload
  raise  "  in_flows counts dont match!" unless trac_malaria.in_flows.size == original_trac.in_flows.size

  original_trac.out_flows.each do |f|
    f.from = trac_malaria
    f.data_response = new_dr
    f.save(false)
  end
  trac_malaria.reload
  raise  "  out_flows counts dont match!" unless trac_malaria.out_flows.size == original_trac.out_flows.size

  #raise "die!"

  raise "users not created correctly" unless trac_malaria.users.size == existing_user_emails.size
  puts "TRAC+ - Malaria created"

  #sanity check
  #u = User.find_by_email("joseph.baguma@gmail.com"); u.password = 'gggggg'; u.password_confirmation = 'gggggg'; u.save!;
end


#
### TRAC - TB
#

puts "\n\nCreating TRAC+ - TB..."
Organization.transaction do
  trac_tb = clone_to_new(original_trac, "TRAC+ - TB")
  original_dr = original_trac.data_responses.first
  new_dr = DataResponse.new(:data_request => original_dr.data_request,
                        :organization => trac_tb)

  existing_user_emails = ["kayirangwae1@rw.cdc.gov", "mukakigerie@yahoo.com"]
  move_users(original_trac, trac_tb, existing_user_emails, new_dr)
  trac_tb.reload
  raise "users not created correctly" unless trac_tb.users.size == existing_user_emails.size
  puts "TRAC+ - Malaria created"

  # no projects

  #sanity check
  #u = User.find_by_email("mukakigerie@yahoo.com"); u.password = 'gggggg'; u.password_confirmation = 'gggggg'; u.save!;

end
puts "TRAC+ - TB created"


#
### TRAC - HIV
#

puts "\n\nMoving TRAC+ to TRAC+ - HIV..."
# just rename from current TRAC.
Organization.transaction do
  original_trac.reload
  original_trac.name = "TRAC+ - HIV"
  original_trac.save!
  expected_users = 4
  raise "a different number of users exist (#{original_trac.users.count}) on original TRAC+ org than expected (#{expected_users})" unless original_trac.users.size == expected_users

  #sanity check
  #u = User.find_by_email("nzecari@yahoo.fr"); u.password = 'gggggg'; u.password_confirmation = 'gggggg'; u.save!;

end
puts "Moved TRAC+ to TRAC+ - HIV"
