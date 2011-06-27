puts "Loading codes.csv..."
cols = {
  :name => 1 ,
  :organization => 2,
  :function => 3,
  :email => 4,
  :site_organization => 5
  }

i = 0
rows = []
FasterCSV.foreach("db/fixes/participant_logins.csv", :headers=>true) do |row|
  begin
    i = i + 1
    a = {}
    cols.each do |k,v|
      a[k]=row[v]
    end
    rows << a
  end
end
puts rows
puts "...Loading codes.csv DONE"

# users without a user present in system (when we look up by email)
rows.each do |r|
  r[:user]=User.find_by_email r[:email]
end

user_not_connected_to_org = rows.select {|s| !s[:user].try(:organization)}.collect{|u| u[:user]}.uniq
#connecting user to the org
# first we found org using heuristic name searching
# Organization.all.collect{|o| o if o.name.include? "National Hospital"}.uniq
# then saved it w the id and using save(false)

missing_users         = rows.select {|s| s[:user]==nil}
orgs_of_missing_users = missing_users.collect{|u| u[:site_organization]}.uniq.collect{|org| {:org => Organization.find_by_name(org), :orig => org} }
missing_orgs          = orgs_of_missing_users.select {|o| o[:org] == nil }
# search for any users on those organizations to see if they have a user w a slightly different email address
users_of_their_orgs   = orgs_of_missing_users.collect {|o| o[:org].try(:users)}

# for each org in the spreadsheet, collect all the orgs pointed to by users of the organization name text
# here we find duplicates for organizations
org_hash = {}
rows.each do |r|
  if r[:user]
    a = org_hash[r[:site_organization]]
    if a
      a << r[:user].organization
    end
    a ||= [r[:user].organization]
    org_hash[r[:site_organization]] = a
  end
end

org_hash.select {|k,v| v.include? nil} # organizations that had users that were not connected to any organization
orgs_w_duplicates = org_hash.select {|k,v| v.uniq.size > 1}

orgs_w_duplicates.each do |name,orgs|
  to_remove = []
  orgs.each do |org|
    unless org == nil
      if org.data_responses.size == 0
        to_remove << org
      end
      raise StandardError, "danger will robinson - #{org.name} has #{org.data_responses.size}" if org.data_responses.size > 1
    end
  end
  orgs_w_duplicates[name] = (orgs - to_remove)
end