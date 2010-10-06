
#re: line 2:  move  kabaroberto@yahoo.fr  from   BUTARE CHU National Hospital | Huye x
  user          = User.find_by_email 'kabaroberto@yahoo.fr'
  old_org       = user.organization
  new_org       = Organization.find_by_name 'BUTARE CHU National Hospital | Huye'
  user.organization = Organization.find(3954); user.password =  user.password_confirmation = user.email; user.save!

#row 27
  user = User.create!(:email => 'fredkagame@yahoo.com', :username => 'fredkagame@yahoo.com', :organization => Organization.find_by_name('BUTARE CHU National Hospital | Huye'),                :password => 'fredkagame@yahoo.com',                :password_confirmation => 'fredkagame@yahoo.com', :roles => ['reporter'])

# delete old duplicate record of CHUB and Fred
Organization.find_by_name('CHUB').destroy
User.find_by_email('fredkagama@yahoo.com').destroy


#lines 21-22
# NDera
# Organization.all.collect{|o| o if o.name.downcase.include? "ndera"}.uniq

user          = User.find_by_email 'kazanathalie@yahoo.com'
new_org       = Organization.find_by_name("CARAES Ndera National Hospital | Gasabo")
user.organization = Organization.find(3954); user.password =  user.password_confirmation = user.email; user.save!

# wont change to thacianos1981@yahoo.fr, since this record already exists. Just reset pw
user          = User.find_by_email 'thacianos1981@gmail.com'
user.password =  user.password_confirmation = user.email; user.save!

  #double check data
  Project.find_by_data_response_id Organization.find(3954).data_responses.first


#line 19 - uwicyp@yahoo.fr
# seems like a broken DReq
user          = User.find_by_email 'uwicyp@yahoo.fr'
org           = user.organization
DataResponse.create! :responding_organization => org, :data_request => DataRequest.first


# line 23 - TRAC+ - TREATMENT AND RESEARCH CENTRE ON HIV/AIDS, TB, MALARIA AND OTHER EPIDEMICS

#seems like multiple Orgs exist

  user          = User.find_by_email 'esrebero@yahoo.com'
  org           = user.organization
  #Organization.all.collect{|o| o if o.name.downcase.include? "trac"}.uniq
  #TODO ! see http://www.pivotaltracker.com/story/show/5294657


# fixing MoH orgs
  #Organization.all.collect{|o| o if (o.name) && (o.name.downcase.include? "inistry")}.uniq
  new_org       = Organization.find(3954) # most active MoH record! First MoH record

  old_org       = Organization.find 4088
    # Update activity.organizations (Institutions Assisted) that point to this org
    puts "Found #{old_org.activities.count} activities"
    old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }
    old_org.activities.each { |a| a.organizations.delete(old_org); a.organizations.push(Organization.find(3954)) }

      #bollocksed it up, so fix manually
      # Activity.find(1872).organizations.push(Organization.find(3954))

    # update Fflows from old_org
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| fflow.organization_id_from = Organization.find(3954).id; fflow.save! }

    # update Fflows in
    # update Fflows to old_org (if any)
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| fflow.organization_id_to = Organization.find(3954).id; fflow.save! }
    #locations
    pp old_org.locations

    old_org.destroy



  old_org       = Organization.find 4067

    # Update activity.organizations (Institutions Assisted) that point to this org
    puts "Found #{old_org.activities.count} activities"
    old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }
    old_org.activities.each { |a| a.organizations.delete(old_org); a.organizations.push(Organization.find(3954)) }

    # update Fflows from old_org
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| fflow.organization_id_from = Organization.find(3954).id; fflow.save! }

    # update Fflows in
    # update Fflows to old_org (if any)
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| fflow.organization_id_to = Organization.find(3954).id; fflow.save! }
    #locations
    pp old_org.locations

    old_org.destroy

  # this org seems to just have users and no data, so move the users
  old_org       = Organization.find 4008
    DataResponse.find_by_organization_id_responder 4008

    # Update activity.organizations (Institutions Assisted) that point to this org
    puts "Found #{old_org.activities.count} activities"

    #...found no data
    old_org.users.each { |u| puts "moving user #{u.email}..." }
    old_org.users.each { |u| u.organization = Organization.find(3954); u.data_response_id_current = Organization.find(3954).data_responses.first.id; u.save! }

    old_org.destroy

  # this was the first MoH record, but the users not active, so move it to most active
  old_org       = Organization.find 3896
    # Update activity.organizations (Institutions Assisted) that point to this org
    puts "Found #{old_org.activities.count} activities"
    old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }
    old_org.activities.each { |a| a.organizations.delete(old_org); a.organizations.push(Organization.find(3954)) }

    # update Fflows from old_org
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| fflow.organization_id_from = Organization.find(3954).id; fflow.save! }

    # update Fflows in
    # update Fflows to old_org (if any)
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| fflow.organization_id_to = Organization.find(3954).id; fflow.save! }
    #locations
    pp old_org.locations

    old_org.users.each { |u| puts "moving user #{u.email}..." }
    old_org.users.each { |u| u.organization = Organization.find(3954); u.data_response_id_current = Organization.find(3954).data_responses.first.id; u.save! }

    old_org.destroy

  old_org       = Organization.find 3997
    # Update activity.organizations (Institutions Assisted) that point to this org
    puts "Found #{old_org.activities.count} activities"
    old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }
    old_org.activities.each { |a| a.organizations.delete(old_org); a.organizations.push(Organization.find(3954)) }

    old_org.users.each { |u| puts "moving user #{u.email}..." }
    old_org.users.each { |u| u.organization = Organization.find(3954); u.data_response_id_current = Organization.find(3954).data_responses.first.id; u.save! }

    old_org.destroy

#  old_org       = Organization.find 3999 #whoops! "Ministry of Gender and Family Promotion"
    # Update activity.organizations (Institutions Assisted) that point to this org
 #   puts "Found #{old_org.activities.count} activities"
  #  old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }
   # old_org.activities.each { |a| a.organizations.delete(old_org); a.organizations.push(Organization.find(3954)) }

    # update Fflows from old_org
    #FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    #FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| fflow.organization_id_from = Organization.find(3954).id; fflow.save! }

    # update Fflows in
    # update Fflows to old_org (if any)
   # FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
  #  FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| fflow.organization_id_to = Organization.find(3954).id; fflow.save! }
    #locations
   # old_org.locations

  #  old_org.users.each { |u| puts "moving user #{u.email}..." }
  #  old_org.users.each { |u| u.organization = Organization.find(3954); u.data_response_id_current = Organization.find(3954).data_responses.first.id; u.save! }

#    old_org.destroy

  old_org       = Organization.find 4005
    # Update activity.organizations (Institutions Assisted) that point to this org
    puts "Found #{old_org.activities.count} activities"
    old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }
    old_org.activities.each { |a| a.organizations.delete(old_org); a.organizations.push(Organization.find(3954)) }

    # update Fflows from old_org
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| fflow.organization_id_from = Organization.find(3954).id; fflow.save! }

    # update Fflows in
    # update Fflows to old_org (if any)
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| fflow.organization_id_to = Organization.find(3954).id; fflow.save! }
    #locations
     old_org.locations

    old_org.users.each { |u| puts "moving user #{u.email}..." }
    old_org.users.each { |u| u.organization = Organization.find(3954); u.data_response_id_current = Organization.find(3954).data_responses.first.id; u.save! }

    old_org.destroy



  #old_org       = Organization.find 4008
    # Update activity.organizations (Institutions Assisted) that point to this org
    puts "Found #{old_org.activities.count} activities"
    old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }
    old_org.activities.each { |a| a.organizations.delete(old_org); a.organizations.push(Organization.find(3954)) }

    # update Fflows from old_org
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| fflow.organization_id_from = Organization.find(3954).id; fflow.save! }

    # update Fflows in
    # update Fflows to old_org (if any)
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| fflow.organization_id_to = Organization.find(3954).id; fflow.save! }
    #locations
    pp old_org.locations

    old_org.users.each { |u| puts "moving user #{u.email}..." }
    old_org.users.each { |u| u.organization = Organization.find(3954); u.data_response_id_current = Organization.find(3954).data_responses.first.id; u.save! }

    old_org.destroy

  old_org       = Organization.find 4050
    old_org.users
    # Update activity.organizations (Institutions Assisted) that point to this org
    puts "Found #{old_org.activities.count} activities"
    old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }
    old_org.activities.each { |a| a.organizations.delete(old_org); a.organizations.push(Organization.find(3954)) }

    # update Fflows from old_org
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| fflow.organization_id_from = Organization.find(3954).id; fflow.save! }

    # update Fflows in
    # update Fflows to old_org (if any)
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| fflow.organization_id_to = Organization.find(3954).id; fflow.save! }
    #locations
    old_org.locations

    old_org.users.each { |u| puts "moving user #{u.email}..." }
    old_org.users.each { |u| u.organization = Organization.find(3954); u.data_response_id_current = Organization.find(3954).data_responses.first.id; u.save! }

    old_org.destroy

  old_org       = Organization.find 4117
    old_org.users
    # Update activity.organizations (Institutions Assisted) that point to this org
    puts "Found #{old_org.activities.count} activities"
    old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }
    old_org.activities.each { |a| a.organizations.delete(old_org); a.organizations.push(Organization.find(3954)) }

    # update Fflows from old_org
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_from(old_org.id).each { |fflow| fflow.organization_id_from = Organization.find(3954).id; fflow.save! }

    # update Fflows in
    # update Fflows to old_org (if any)
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| puts "  Updating fflow #{fflow.id} by Org: #{fflow.data_response.responding_organization}" }
    FundingFlow.find_all_by_organization_id_to(old_org.id).each { |fflow| fflow.organization_id_to = Organization.find(3954).id; fflow.save! }
    #locations
    old_org.locations

    old_org.users.each { |u| puts "moving user #{u.email}..." }
    old_org.users.each { |u| u.organization = Organization.find(3954); u.data_response_id_current = Organization.find(3954).data_responses.first.id; u.save! }

    old_org.destroy

  #    user = User.find_by_email 'houngbok@rw.afro.who.int'; user.password =  user.password_confirmation = user.email; user.save!
  #    user = User.find_by_username 'admin'; user.password =  user.password_confirmation = 'sys123!@#'; user.save!

  # double check chub - we left some data hanging!

    #old_org = Organization.find_by_name('CHUB')
    # Update activity.organizations (Institutions Assisted) that point to this org
    #puts "Found #{old_org.activities.count} activities"
    #old_org.activities.each { |a| puts "  Updating activity #{a.id} by Org: #{a.organization}" }

    # fixes "ACM - Atelier Central de Maintenance  / Central Mai..."
    a = Activity.find(1301); a.organizations.push( Organization.find_by_name 'BUTARE CHU National Hospital | Huye' )
    a = Activity.find(1767); a.organizations.push( Organization.find_by_name 'BUTARE CHU National Hospital | Huye' )
