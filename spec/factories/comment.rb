Factory.define :comment, :class => Comment do |f|
  f.comment     { 'comment' }
  f.commentable { Factory.create(:project) }
  f.user        { Factory.create(:reporter) }
end
