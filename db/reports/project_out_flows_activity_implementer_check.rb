require 'set'

projects = Project.all
ids = []

projects.each do |project|
  if project.activities.map(&:implementer).uniq.to_set == project.out_flows.map(&:to).uniq.to_set
    ids << project.id
  end
end

# these projects has good data, other not
puts ids.join(', ')
