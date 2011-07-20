Factory.define :comment, :class => Comment do |f|
  f.comment     { 'comment' }
  f.user        { Factory.create(:reporter) }
end
