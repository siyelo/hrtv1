class Indicator < ActiveRecord::Base
  has_and_belongs_to_many :activities
  attr_accessible :name, :description, :source
end
