require 'spec_helper'

describe ClassificationsController do
  before :each do
    organization   = Factory(:organization)
    data_request   = Factory(:data_request, :organization => organization)
    @data_response = organization.latest_response
    @reporter = Factory.create(:reporter, :organization => organization)
    login @reporter
  end

  context "when clicked on 'Save'" do
    it "redirects to long_term_budget_path for current year" do
      CodeAssignment.stub(:mass_update_classifications).and_return(true)
      put :update, :id => 'CodingBudget',
        :response_id => @data_response.id, :commit => "Save"
      response.should redirect_to(edit_response_classification_url(@data_response, 'CodingBudget'))
    end
  end

  context "when clicked on 'Save & Next'" do
    it "redirects to long_term_budget_path for current year" do
      CodeAssignment.stub(:mass_update_classifications).and_return(true)
      put :update, :id => 'CodingBudget',
        :response_id => @data_response.id, :commit => "Save & Next >"
      response.should redirect_to(long_term_budget_path(Time.now.year))
    end
  end

end
