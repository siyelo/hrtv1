require 'spec_helper'

describe Admin::ReportsController do
  before :each do
    login_as_admin
  end

  describe "#mark_implementer_splits" do
    context "file is blank" do
      it "sets flash error" do
        put :mark_implementer_splits, :file => nil
        flash[:error].should == "Please select a file to upload"
      end
    end

    context "file is correct" do
      it "sets flash notice" do
        file = ActionController::TestUploadedFile.new('spec/fixtures/activity_overview.csv', "text/csv")
        ImplementerSplit.should_receive(:mark_double_counting).and_return(true)
        put :mark_implementer_splits, :file => file
        flash[:notice].should == "Your file is being processed, please reload this page in a couple of minutes to see the results"
      end
    end

    context "valid format" do
      it "accepts csv format" do
        file = ActionController::TestUploadedFile.new('spec/fixtures/activity_overview.csv', "text/csv")
        ImplementerSplit.should_receive(:mark_double_counting).and_return(true)
        put :mark_implementer_splits, :file => file
        flash[:notice].should == "Your file is being processed, please reload this page in a couple of minutes to see the results"
      end

      it "accepts zip format" do
        file = ActionController::TestUploadedFile.new('spec/fixtures/activity_overview.zip', "application/zip")
        ImplementerSplit.should_receive(:mark_double_counting).and_return(true)
        put :mark_implementer_splits, :file => file
        flash[:notice].should == "Your file is being processed, please reload this page in a couple of minutes to see the results"
      end
    end

    context "invalid format" do
      it "does not accept pdf format" do
        file = ActionController::TestUploadedFile.new('spec/fixtures/activity_overview.pdf', "application/pdf")
        put :mark_implementer_splits, :file => file
        flash[:error].should == "Invalid file format. Please select .csv or .zip format."
      end
    end
  end
end
