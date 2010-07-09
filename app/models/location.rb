class Location < Code
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :activities
end
