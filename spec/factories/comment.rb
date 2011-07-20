Factory.define :comment, :class => Comment do |f|
  f.title       { 'title' }
  f.comment     { 'comment' }
  f.user        { Factory.create(:reporter) }
end
