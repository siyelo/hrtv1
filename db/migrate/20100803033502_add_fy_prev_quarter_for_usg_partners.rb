class AddFyPrevQuarterForUsgPartners < ActiveRecord::Migration
  def self.up
    add_column :funding_flows, :spend_q4_prev, :decimal
    add_column :activities, :spend_q4_prev, :decimal
  end

  def self.down
    remove_column :activities, :spend_q4_prev
    remove_column :funding_flows, :spend_q4_prev
  end
end
