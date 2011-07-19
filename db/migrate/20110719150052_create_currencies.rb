class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :conversion
      t.float :rate
      t.timestamps
    end
    load 'db/fixes/20110719_load_currencies_into_db.rb'
  end

  def self.down
    drop_table :currencies
  end
  
  
end
