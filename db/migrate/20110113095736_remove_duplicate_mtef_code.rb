class RemoveDuplicateMtefCode < ActiveRecord::Migration
  def self.up
    puts ActiveRecord::Base.connection.execute("
      update code_assignments
      set code_id = 1197
      where code_id = 1207")
    puts Code.find("1207").delete + " deleted "

  end

  def self.down
    raise "Irreversible Migration"
  end
end
