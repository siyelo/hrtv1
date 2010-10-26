require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :code_assignment, :class => CodeAssignment do |f|
  f.activity        { Factory.create :activity  }
  f.code            { Factory.create :code }
  f.amount          { Sham.amount }
end

Factory.define :coding_budget, :class => CodingBudget, :parent => :code_assignment do |f|
    f.code            { Factory.create :mtef_code }
end
