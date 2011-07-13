class RemoveUsgPepfarOrg < ActiveRecord::Migration
  def self.up
    begin
      Organization.find_by_name('USG').destroy
    rescue
    end

    begin
      Organization.find_by_name('USG - PEPFAR').destroy
    rescue
    end

    begin
      Organization.find_by_name('HRSA/PEPFAR').destroy
    rescue
    end

  end

  def self.down
    puts 'irreversible migration'
  end
end
