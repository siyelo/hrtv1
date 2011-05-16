require 'validators'
class DataRequest < ActiveRecord::Base

  ### Attributes
  attr_accessible :organization_id, :title, :final_review,
                  :start_date, :end_date, :due_date, :budget, :spend,
                  :year_q2, :year_q3, :year_q4, :year_q5, :purposes, :locations,
                  :inputs, :service_levels

  ### Associations
  belongs_to :organization
  has_many :data_responses, :dependent => :destroy

  ### Validations
  validates_presence_of :organization_id, :title
  validates_date :due_date
  validates_date :start_date
  validates_date :end_date
  validates_dates_order :start_date, :end_date, :message => "Start date must come before End date."

  def status
    return 'Final review' if final_review?
    return 'In progress'
  end

  def spend_and_budget?
    spend? && budget?
  end

  def only_spend?
    spend? && !budget?
  end

  def only_budget?
    budget? && !spend?
  end

end



# == Schema Information
#
# Table name: data_requests
#
#  id              :integer         not null, primary key
#  organization_id :integer
#  title           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  due_date        :date
#  start_date      :date
#  end_date        :date
#  budget          :boolean         default(TRUE), not null
#  spend           :boolean         default(TRUE), not null
#  final_review    :boolean         default(FALSE)
#

