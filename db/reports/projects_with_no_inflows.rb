projects = Project.all
ids = []

projects.each do |project|
  if project.in_flows.empty?
    ids << project.id
  end
end

puts ids.join(', ')
