class CreateHelpRequests < ActiveRecord::Migration
  def self.up
    create_table :help_requests do |t|
      t.string :email
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :help_requests
  end
end
