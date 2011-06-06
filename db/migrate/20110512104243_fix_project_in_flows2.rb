class FixProjectInFlows2 < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110512_fix_project_in_flows2.rb'
  end

  def self.down
    puts 'Irreversible migration'
  end
end
