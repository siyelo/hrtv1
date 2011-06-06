Factory.define :comment, :class => Comment do |f|
  f.title       { 'title' }
  f.comment     { 'comment' }
  f.commentable { Factory.create(:project) }
  f.user        { Factory.create(:user) }
end
