class Project < ActiveRecord::Base
  acts_as_commentable

  has_and_belongs_to_many :activities
  has_and_belongs_to_many :locations
  has_many :funding_flows, :dependent => :nullify

  has_many :funding_sources, :through => :funding_flows, :class_name => "Organization", :source => :from
  has_many :providers, :through => :funding_flows, :class_name => "Organization", :source => :to

  validates_presence_of :name
  validates_numericality_of :expected_total

  attr_accessible :name, :description, :expected_total

  def to_s
    result = ''
    result = name unless name.nil?
    result
  end

  # TODO... GR: this is view code - must be moved out of the model
  def to_label #so text doesn't spill over in nested scaffs.
    if to_s.length > 21
      to_s[0,20]+'...'
    else
      to_s
    end
  end

  def valid_providers
    self.providers
  end
end
