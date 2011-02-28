class AddDueDateToRequest < ActiveRecord::Migration
  def self.up
    add_column :data_requests, :due_date,    :date
    load 'db/fixes/20110221_add_due_date_to_request.rb'
  end

  def self.down
    remove_column :data_requests, :due_date
  end
end
