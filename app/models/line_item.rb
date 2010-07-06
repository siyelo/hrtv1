class LineItem < ActiveRecord::Base
  acts_as_commentable
  belongs_to :activity
  
  # below should be STI's from codes table, include when done
  # belongs_to :hssp_strategic_objective
  # belongs_to :mtefp

  def to_label
    @s="Line Item: "
    if amount.nil?
      @s+"<No Amount>"
    else
      @s+amount.to_s
    end
  end
end
