class RemoveInvalidFundingFlows < ActiveRecord::Migration
  def self.up
    puts "Before DB fix: #{FundingFlow.count} funding flows in database"

    # destroy funding flows where:
    # - foreign_keys are blank:
    #   - data_response_id
    #   - project_id
    #   - organization_id_from
    #   - organization_id_to
    # - associated models are blank?:
    #   - project
    #   - data_response
    #   - from
    #   - to
    FundingFlow.all.each do |ff| 
      ff.destroy if ff.project_id.blank? || 
                    ff.data_response_id.blank? || 
                    ff.organization_id_from.blank? || 
                    ff.organization_id_to.blank? ||
                    !ff.project || 
                    !ff.data_response || 
                    !ff.from || 
                    !ff.to
    end

    puts "After DB fix: #{FundingFlow.count} funding flows in database"
  end

  def self.down
   puts "irreversible migration - data fix"
  end
end
