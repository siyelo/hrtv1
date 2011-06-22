#
# find all Activities with broken foreign key reference to DataResponse
# and delete them
#

puts "=> finding all Activities with broken foreign key reference to DataResponse"
broken = []
Activity.all.each do |a|
  begin
    a.organization
  rescue RuntimeError => e
    broken << a
  end
end

puts "=> found #{broken.count} broken activities/other costs."

unless broken.empty?
  broken.each {|a| puts "Deleting hanging Activity #{a.id}:"; ap a; a.destroy}
end
