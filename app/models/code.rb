class Code < ActiveRecord::Base
  include NumberHelper
  extend NumberHelper
  ACTIVITY_ROOT_TYPES   = %w[Mtef Nha Nasa Nsp]

  acts_as_commentable

  attr_accessible :long_display, :short_display, :description, :start_date, :end_date

  has_many :code_assignments, :foreign_key => :code_id
  has_many :activities, :through => :code_assignments

  named_scope :with_type,       lambda { |type| {:conditions => ["codes.type = ?", type]} }

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set

  named_scope :for_activities, :conditions => ["codes.type in (?)", ACTIVITY_ROOT_TYPES]
  named_scope :ordered, :order => 'lft'

  ### Public Methods

  def leaf_assigns_for_activities_for_code_set(type, leaf_ids, activities = self.activities)
    CodeAssignment.with_code_id(id).with_type(type).with_activities(activities).find(:all, :conditions => ["sum_of_children = 0 or code_id in (?)", leaf_ids])
  end

  def leaf_assigns_for_activities(type, activities = self.activities)
    CodeAssignment.with_code_id(id).with_type(type).with_activities(activities).sort_cached_amt.find(:all, :conditions => ["(sum_of_children = 0 or code_id in (?))", self.class.leaves.map(&:id)])
  end

  def sum_of_assignments_for_activities (type, activities = self.activities)
    CodeAssignment.with_code_id(id).with_type(type).with_activities(activities).sum(:cached_amount)
  end

  # todo recurse with array then join
  def self.treemap_for_codes(code_roots, codes, type, activities)
    # format is my value, parent value, box_area_value, coloring_value
    rows = []
    sum_of_roots = 0
    code_roots.each do |r|
      sum_of_roots += r.sum_of_assignments_for_activities(type,activities)
    end

    root_name = "#{n2c(sum_of_roots)}: All Codes"
    rows << [root_name, nil, sum_of_roots, 0]

    code_roots.each do |r|
      parent_display_cache = {} # code => display_value , used to connect rows
      parent_display_cache[r.parent] = root_name
      Code.each_with_level(r.self_and_descendants) do |c,level|
        c.treemap_row(rows, type, activities, parent_display_cache, level, sum_of_roots) if codes.include?(c)
      end
    end

    rows
  end

  def treemap_row(rows, type, activities, treemap_parent_values, level, total_for_percentage)
    name  = to_s_prefer_official
    sum   = sum_of_assignments_for_activities(type, activities)
    if sum > 0 #TODO add % of total as well, abbrev amount
      name_w_sum = "#{n2c(sum.fdiv(total_for_percentage)*100)}%: #{name}"
      if treemap_parent_values.values.include?(name_w_sum)
        name_w_sum = "#{n2c(sum)} (2): #{name}"
      end
      treemap_parent_values[self] = name_w_sum
      my_parent_treemap_value = treemap_parent_values[parent]
      rows << [name_w_sum, my_parent_treemap_value, sum, sum]
    end
  end

  def name
    to_s
  end

  def to_s
    short_display
  end

  def to_s_prefer_official
   official_name ? official_name : to_s
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

