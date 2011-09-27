Factory.define :implementer_split do |f|
  f.organization    { Factory.build(:organization) }
  f.spend           { 1.23 }
  f.budget          { 1.23 }
end

#deprecated
Factory.define :sub_activity, :parent => :implementer_split do |f|
end