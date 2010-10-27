class Code < ActiveRecord::Base
  ACTIVITY_ROOT_TYPES   = %w[Mtef Nha Nasa Nsp]

  acts_as_commentable

  attr_accessible :long_display, :short_display, :description, :start_date, :end_date

  has_many :code_assignments, :foreign_key => :code_id
  has_many :activities, :through => :code_assignments

  named_scope :with_type,       lambda { |type| {:conditions => ["codes.type = ?", type]} }
  def self.leaves_for_codes(code_ids)

  end

  def self.deepest_nesting
    @depest_nesting ||= self.roots_with_level.collect{|a| a[0]}.max - 1
  end
  def self.roots_with_level
    a = []
    self.roots.each do |nsp_root|
      self.each_with_level(nsp_root.self_and_descendants) do |code, level|       # each_with_level() is faster than level()
        a << [level, code.id]
      end
    end
    a
  end
  def leaf_assigns_for_activities_for_code_set(type, leaf_ids, activities = self.activities)
    CodeAssignment.with_code_id(id).with_type(type).with_activities(activities).find(:all, :conditions => ["sum_of_children = 0 or code_id in (?)", leaf_ids])
  end
 
  def leaf_assigns_for_activities(type, activities = self.activities)
    CodeAssignment.with_code_id(id).with_type(type).with_activities(activities).sort_cached_amt.find(:all, :conditions => ["(sum_of_children = 0 or code_id in (?))", self.class.leaves.map(&:id)])
  end
  
  def sum_of_assignments_for_activities (type,activities = self.activities)
    CodeAssignment.with_code_id(id).with_type(type).with_activities(activities).sum(:cached_amount)
  end

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set

  named_scope :for_activities, :conditions => ["codes.type in (?)", ACTIVITY_ROOT_TYPES]
  named_scope :ordered, :order => 'lft'

  ### methods

  def name
    to_s
  end

  def to_s
    short_display
  end

  def to_s_with_external_id
    to_s + " (" + (external_id.nil? ? 'n/a': external_id) + ")"
  end
end

# == Schema Information
#
# Table name: codes
#
#  id                  :integer         primary key
#  parent_id           :integer
#  lft                 :integer
#  rgt                 :integer
#  short_display       :string(255)
#  long_display        :string(255)
#  description         :text
#  created_at          :timestamp
#  updated_at          :timestamp
#  start_date          :date
#  end_date            :date
#  replacement_code_id :integer
#  type                :string(255)
#  external_id         :string(255)
#  hssp2_stratprog_val :string(255)
#  hssp2_stratobj_val  :string(255)
#  official_name       :string(255)
#

