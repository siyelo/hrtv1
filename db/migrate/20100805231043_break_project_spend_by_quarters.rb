class BreakProjectSpendByQuarters < ActiveRecord::Migration
  def self.up
    %w[q1 q2 q3 q4 q4_prev].each do |quarter|
        add_column :projects, "spend_#{quarter}", :decimal
    end
  end

  def self.down
    %w[q1 q2 q3 q4 q4_prev].each do |quarter|
        remove_column :projects, "spend_#{quarter}"
    end
  end
end
