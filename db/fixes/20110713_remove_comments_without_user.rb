puts "Comments count before: #{Comment.count}"

Comment.all.each do |comment|
  comment.destroy unless comment.user
end

puts "Comments count after: #{Comment.count}"
