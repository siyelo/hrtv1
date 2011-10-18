class RenamingCodes < ActiveRecord::Migration
  def self.up
    if Rails.env != "test" && Rails.env != "cucumber"
      Code.reset_column_information
      parent_code = Code.find_by_short_display('Monitoring And Evaluation Of Health Activities')
      changing_code = Code.find(:first, :conditions => {:parent_id => parent_code.id, :short_display => 'Financial Support'})
      changing_code.short_display = "Monitoring And Evaluation For HIV/AIDS"
      changing_code.save!
      changing_code = nil;
      changing_code = Code.find_by_short_display('General Monitoring and Evaluation')
      changing_code.short_display = "General Monitoring And Evaluation For HIV/AIDS"
      changing_code.save!
    end
  end

  def self.down
    puts 'IRREVERSIBLE MIGRATION'
  end
end
