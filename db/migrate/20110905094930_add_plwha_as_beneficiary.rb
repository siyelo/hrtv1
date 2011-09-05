class AddPlwhaAsBeneficiary < ActiveRecord::Migration
  def self.up
    Beneficiary.reset_column_information
    Beneficiary.create!(:short_display => "PLWHA")
  end

  def self.down
    b = Beneficiary.find_by_short_display('PLWHA')
    b.destroy
  end
end
