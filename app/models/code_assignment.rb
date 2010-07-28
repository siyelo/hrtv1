# == Schema Information
#
# Table name: code_assignments
#
#  id          :integer         not null, primary key
#  activity_id :integer
#  code_id     :integer
#  code_type   :string(255)
#  amount      :decimal(, )
#  type        :string(255)
#

class CodeAssignment < ActiveRecord::Base
  after_create do |record|
    if record.code.short_display == "Technical Assistance"
      ta=ActivityCostCategory.find_by_short_display("Technical Assistance")
      record.activity.lineItems.each do |l|
        if l.activity_cost_category_id == ta
          ta=nil
        end
      end

      if ta
        record.activity.lineItems.create(
        :spend => record.amount,
        :activity_cost_category_id => ta)
      end
    end
  end
  belongs_to :activity
  belongs_to :code

  validates_presence_of :activity, :code

end
