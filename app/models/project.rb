class Project < ActiveRecord::Base
  acts_as_commentable
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :locations

  has_many :funding_flows, :dependent => :nullify

  def to_s
    name
  end
end
