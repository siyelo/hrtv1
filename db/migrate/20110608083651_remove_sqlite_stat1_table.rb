class RemoveSqliteStat1Table < ActiveRecord::Migration
  def self.up
    drop_table :"sqlite_stat1" if self.table_exists?("sqlite_stat1")
  end

  def self.down
    puts "irreversible migration"
  end
end
