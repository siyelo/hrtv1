class MoveJsi < ActiveRecord::Migration
  def self.up
    if Rails.env == "production"
      load 'db/fixes/20110831_move_jsi_projects.rb'
    end
  end

  def self.down
  end
end
