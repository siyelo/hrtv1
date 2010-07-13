class UpdateFundingAmtsFundingFlows < ActiveRecord::Migration
  def self.up
    %w[committment_from disbursement_from spending_from 
      committment_to disbursement_to spending_to].each do |c|
        remove_column :funding_flows, c
      end
    add_column :funding_flows, :budget, :decimal
  
    %w[q1 q2 q3 q4].each do |quarter|
        add_column :funding_flows, "spend_#{quarter}", :decimal
      end
  end

  def self.down
    %w[committment_from disbursement_from spending_from 
      committment_to disbursement_to spending_to].each do |c|
        add_column :funding_flows, c, :decimal
      end 
    remove_column :funding_flows, :budget
  
    %w[q1 q2 q3 q4].each do |quarter|
        remove_column :funding_flows, "spend_#{quarter}"
      end
  end
end
