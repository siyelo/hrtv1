# == Schema Information
#
# Table name: codes
#
#  id                  :integer         not null, primary key
#  parent_id           :integer
#  lft                 :integer
#  rgt                 :integer
#  short_display       :string(255)
#  long_display        :string(255)
#  description         :text
#  created_at          :datetime
#  updated_at          :datetime
#  start_date          :date
#  end_date            :date
#  replacement_code_id :integer
#  type                :string(255)
#  external_id         :string(255)
#

class Code < ActiveRecord::Base
  acts_as_commentable

  attr_accessible :long_display, :short_display, :description, :start_date, :end_date

  has_many :code_assignments, :foreign_key => :code_id
  has_many :activities, :through => :code_assignments

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set

  named_scope :activity_codes, :conditions => ["type in (?)", Activity::VALID_ROOT_TYPES], :order => quoted_left_column_name
  named_scope :other_cost_codes, :conditions => ["type in (?)", OtherCost::VALID_ROOT_TYPES], :order => quoted_left_column_name
  named_scope :valid_activity_codes, :conditions => ["type in (?)", Activity::VALID_ROOT_TYPES]

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
