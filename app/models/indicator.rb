class Indicator < ActiveRecord::Base
  acts_as_commentable
  has_and_belongs_to_many :activities
  attr_accessible :name, :description, :source
end
