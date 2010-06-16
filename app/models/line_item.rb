class LineItem < ActiveRecord::Base
  belongs_to :activity
 
 # below should be STI's from codes table, imo
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
