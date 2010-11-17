require File.dirname(__FILE__) + '/../spec_helper'

describe FundingFlow do
  
  describe "creating a project record" do
    subject { Factory(:funding_flow) }
    it { should be_valid }
    it { should belong_to :from }
    it { should belong_to :to }
    it { should belong_to :project }
    it { should validate_presence_of(:project_id) }
    it { should validate_presence_of(:organization_id_to) }
    it { should validate_presence_of(:organization_id_from) }
    #it { should delegate :organization, :to => :project } #need shmacros
    
    # TODO: deprecate in favour of delegate to project
    it { should belong_to :data_response }  #it { should delegate :data_response, :to => :project } #need shmacros
    it { should validate_presence_of(:data_response_id) }
        
  end
        
  
end
