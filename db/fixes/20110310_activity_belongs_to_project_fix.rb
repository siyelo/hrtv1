class Activity < ActiveRecord::Base
  has_and_belongs_to_many :projects
  belongs_to :project
  belongs_to :data_response
  delegate :organization, :to => :data_response
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
Activity.find(:all).each do |activity|
  puts "Updating activity #{activity.id}"
  if activity.projects.length == 1
    project = activity.projects.first
    activity.project = project
    activity.save(false)
  elsif activity.projects.length > 1
    activities << activity
  end
end

puts "Following activities have more than one project (SEND EMAIL TO ORGANIZATIONS)"

activities.group_by{|a| a.organization}.each do |org, acts|
  puts "organization: #{org.id}; activities: #{acts.map(&:id).join(', ')}"
end
