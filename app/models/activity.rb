class Activity < ActiveRecord::Base
  acts_as_commentable
  has_and_belongs_to_many :projects 
  has_and_belongs_to_many :indicators
  has_many :lineItems

  validates_presence_of :name
end
