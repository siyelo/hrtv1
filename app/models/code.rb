class Code < ActiveRecord::Base
  acts_as_commentable

  attr_accessible :long_display, :short_display, :description, :start_date, :end_date

  has_many :code_assignments, :foreign_key => :code_id
  has_many :activities, :through => :code_assignments

  named_scope :root_nodes, :conditions => "parent_id is NULL"

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set

  def to_label
    to_s
  end

  def name
    to_s
  end

  def to_s
    short_display
  end

end
