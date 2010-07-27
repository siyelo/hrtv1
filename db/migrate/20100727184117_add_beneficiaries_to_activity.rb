class AddBeneficiariesToActivity < ActiveRecord::Migration
  def self.up
    create_table :activities_beneficiaries, :id=>false do |t|
      t.references :activity
      t.references :beneficiary
    end

  end

  def self.down
    drop_table :activities_beneficiaries
  end
end
