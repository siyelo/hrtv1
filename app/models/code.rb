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
  
  
  STRAT_PROG_TO_CODES_FOR_TOTALING = {
    "Quality Assurance" => [ 6,7,8,9,11],
    "Commodities, Supply and Logistics" => [5],
    "Infrastructure and Equipment" => [4],
    "Health Financing" => [3],
    "Human Resources for Health" => [2],
    "Governance" => [101,103],
    "Planning and M&E" => [102,104,105,106]
  }

  STRAT_OBJ_TO_CODES_FOR_TOTALING = {
    "Across all 3 objectives" => [1,201,202,203,204,206,207,208,3,4,5,7,11],
    "b. Prevention and control of diseases" => [205,9],
    "c. Treatment of diseases" => [601,602,603,604,607,608,6011,6012,6013,6014,6015,6016],
    "a. FP/MCH/RH/Nutrition services" => [605,609,6010, 8]
  }

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
