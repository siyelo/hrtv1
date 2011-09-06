  #moving SCMS project to JSI organization

  jsi_dr    = Organization.find_by_name('JSI').latest_response
  scms_dr = Organization.find_by_name('JSI/SCMS').latest_response
  scms_project = scms_dr.projects.find_by_name('Supply Chain Management System (SCMS)')

  if scms_project && jsi_dr
    puts "moving scms_project to jsi organization"
    scms_project.data_response = jsi_dr
    scms_project.activities.each { |a| a.data_response = jsi_dr; a.save! }
    scms_project.save!
  end


  jsi = Organization.find_by_name('JSI')

  if jsi
    puts "creating JSI R+T organization"
    jsi_rt = Organization.create!(:name => "JSI R+T", :raw_type => jsi.raw_type, :fosaid => jsi.fosaid,
                                  :currency => jsi.currency, :fiscal_year_start_date => jsi.fiscal_year_start_date,
                                  :fiscal_year_end_date => jsi.fiscal_year_end_date, :contact_name => jsi.contact_name,
                                  :contact_position => jsi.contact_position, :contact_phone_number => jsi.contact_phone_number,
                                  :contact_main_office_phone_number => jsi.contact_main_office_phone_number,
                                  :contact_office_location => jsi.contact_office_location)


    rit_project = jsi_dr.projects.find_by_name('Rwanda Injection Safety Project')
    if rit_project
      rit_project.data_response = jsi_rt.latest_response
      rit_project.activities.each { |a| a.data_response = jsi_rt.latest_response; a.save! }
      rit_project.save!
    end

    jsi_users = ["agatera@rw.pfscm.org", "gmuhire@jsi.org.rw", "jndahinyuka@jsi.org.rw",
      "karugu.fifi@gmail.com", "npehe@jsi.com", "rutage@yahoo.fr","dhanyurwimfura@jsi.org.rw"]

    rt_users = ["erutagengwa@jsi.org.rw","igasimbi@jsi.org.rw","jkaligirwa@jsi.org.rw",
      "madiallo@jsi.org.rw","obizimana@jsi.org.rw"]

    jsi_users.each do |u|
      user = User.find_by_email(u)
      user.current_response = jsi.latest_response
      user.organization = jsi; user.save!
    end


    rt_users.each do |u|
      user = User.find_by_email(u)
      user.current_response = jsi_rt.latest_response
      user.organization = jsi_rt; user.save!
    end
  end

