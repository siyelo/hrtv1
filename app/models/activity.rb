class Activity < ActiveRecord::Base
  has_and_belongs_to_many :indicators
  has_many :lineItems

  validates_presence_of :name
end
