class CleanSessionsTable < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("DELETE FROM sessions")
  end

  def self.down
    puts 'irreversible migration'
  end
end
