class RemoveProjectsWithoutDataResponse < ActiveRecord::Migration
  def self.up
    Project.all.select{ |p| !p.data_response }.each{ |p| p.delete }
  end

  def self.down
    puts 'irreversible migration'
  end
end
