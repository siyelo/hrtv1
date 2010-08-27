# == Schema Information
#
# Table name: line_items
#
#  id                        :integer         primary key
#  description               :text
#  activity_id               :integer
#  created_at                :timestamp
#  updated_at                :timestamp
#  activity_cost_category_id :integer
#  budget                    :decimal(, )
#  spend                     :decimal(, )
#

class LineItem < ActiveRecord::Base
  acts_as_commentable
  belongs_to :activity
  belongs_to :activity_cost_category
  
  # below should be STI's from codes table, include when done
  # belongs_to :hssp_strategic_objective
  # belongs_to :mtefp

  def to_s
    @s="Cost Breakdown: "
    if activity_cost_category.nil?
      @s+"<No Category>"
    else
      @s+activity_cost_category.to_s
    end
  end
end
