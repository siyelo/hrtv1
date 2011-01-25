class AddSubAccountAndNhaCodeAndNasaCodeToCodes < ActiveRecord::Migration
  def self.up
    add_column :codes, :sub_account, :string
    add_column :codes, :nha_code, :string
    add_column :codes, :nasa_code, :string

    load 'db/seed_files/codes.rb'
  end

  def self.down
    remove_column :codes, :nasa_code
    remove_column :codes, :nha_code
    remove_column :codes, :sub_account
  end
end
