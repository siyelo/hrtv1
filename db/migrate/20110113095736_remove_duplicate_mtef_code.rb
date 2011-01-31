class RemoveDuplicateMtefCode < ActiveRecord::Migration
  def self.up

    begin
      dupe_id = 1207
      real_id = 1197
      dupe = Code.find(dupe_id)
      real = Code.find(real_id)

      puts ActiveRecord::Base.connection.execute("
        update code_assignments
        set code_id = #{real_id}
        where code_id = #{dupe_id}")

      puts "#{dupe.delete} deleted " if dupe
    rescue ActiveRecord::RecordNotFound
      puts "Didn't remove duplicate that wasn't found"
    end

  end

  def self.down
    puts "Irreversible Migration that removed duplicate"
  end
end
