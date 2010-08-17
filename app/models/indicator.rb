# == Schema Information
#
# Table name: indicators
#
#  id          :integer         primary key
#  name        :string(255)
#  description :text
#  source      :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp
#

class Indicator < ActiveRecord::Base
  acts_as_commentable
  has_and_belongs_to_many :activities
  attr_accessible :name, :description, :source
end
