class Activity < ActiveRecord::Base
  has_and_belongs_to_many :projects
  belongs_to :data_response
  delegate :organization, :to => :data_response
  named_scope :only_simple,       { :conditions => ["activities.type IS NULL
                                    OR activities.type IN (?)", ["OtherCost"]] }
end
class SubActivity < Activity
end
class OtherCost < Activity
end
class Project < ActiveRecord::Base
  has_and_belongs_to_many :activities
  has_many :activities
end

activities = []
Activity.only_simple.all.each do |activity|
  puts "Updating activity #{activity.id}"
  if activity.projects.length == 1
    project = activity.projects.first
    activity.project_id = project.id
    activity.save(false)
    puts "   assigned project #{activity.project_id}"
  elsif activity.projects.length > 1
    activities << activity
  end
end

puts "Following activities have more than one project (SEND EMAIL TO ORGANIZATIONS)"

activities.group_by{|a| a.organization}.each do |org, acts|
  puts "organization: #{org.id}; activities: #{acts.map(&:id).join(', ')}"
end
