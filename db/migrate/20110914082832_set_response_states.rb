class SetResponseStates < ActiveRecord::Migration
  def self.up
    DataResponse.find(:all).each do |data_response|
      if data_response.submitted_for_final || data_response.submitted
        state = 'submitted'
      elsif (data_response.projects.present?)
        state = 'started'
      else
        state = 'unstarted'
      end

      data_response.state = state
      data_response.save(false)
    end
  end

  def self.down
    puts 'irreversible migration'
  end
end
