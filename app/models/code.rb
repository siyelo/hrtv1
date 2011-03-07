class Code < ActiveRecord::Base
  ACTIVITY_ROOT_TYPES   = %w[Mtef Nha Nasa Nsp]

  ### Comments
  acts_as_commentable

  ### Attributes
  attr_accessible :long_display, :short_display, :description, :start_date, :end_date

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set

  ### Associations
  has_many :code_assignments
  has_many :activities, :through => :code_assignments

  ### Named scope
  named_scope :with_type,  lambda { |type| {:conditions => ["codes.type = ?", type]} }
  named_scope :with_types, lambda { |types| {:conditions => ["codes.type IN (?)", types]} }
  named_scope :for_activities, :conditions => ["codes.type in (?)", ACTIVITY_ROOT_TYPES]
  named_scope :ordered, :order => 'lft'

  def self.deepest_nesting
    @depest_nesting ||= self.roots_with_level.collect{|a| a[0]}.max + 1
  end

  def self.roots_with_level
    a = []
    self.roots.each do |root|
      self.each_with_level(root.self_and_descendants) do |code, level|
        a << [level, code.id]
      end
    end
    a
  end

  def leaf_assignments_for_activities(type, activities)
    if leaf?
      code_assignments.with_type(type.to_s).
                       with_activities(activities).
                       cached_amount_desc.
                       find(:all, 
                            :conditions => ["sum_of_children = 0"],
                            :order => "code_assignments.cached_amount DESC"
                           )
    else
      []
    end
  end

  def sum_of_assignments_for_activities(coding_klass, activities)
    code_assignments.with_type(coding_klass.to_s).with_activities(activities).sum(:cached_amount_in_usd)
  end

  def name
    short_display
  end

  def to_s
    short_display
  end

  def to_s_prefer_official
    official_name || short_display
  end

  def to_s_with_external_id
    "#{short_display} (#{external_id || 'n/a'})"
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
#  comments_count      :integer         default(0)
#  sub_account         :string(255)
#  nha_code            :string(255)
#  nasa_code           :string(255)
#

