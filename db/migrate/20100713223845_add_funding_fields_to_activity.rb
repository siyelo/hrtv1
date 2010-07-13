class AddFundingFieldsToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :budget, :decimal
  
    %w[q1 q2 q3 q4].each do |quarter|
        add_column :activities, "spend_#{quarter}", :decimal
      end
  end

  def self.down
    remove_column :activities, :budget
  
    %w[q1 q2 q3 q4].each do |quarter|
        remove_column :activities, "spend_#{quarter}"
      end
  end
end
