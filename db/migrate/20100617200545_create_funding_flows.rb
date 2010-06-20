class CreateFundingFlows < ActiveRecord::Migration
  def self.up
    create_table :funding_flows do |t|
      t.integer :organization_id_from
      t.integer :organization_id_to
      t.integer :project_id
      
      t.decimal :committment_from
      t.decimal :disbursement_from
      t.decimal :spending_from
      
      t.decimal :committment_to
      t.decimal :disbursement_to
      t.decimal :spending_to

      t.timestamps
    end
  end

  def self.down
    drop_table :funding_flows
  end
end
