class Beneficiary < Code
  has_and_belongs_to_many :activities # organizations targeted by this activity / aided

end
