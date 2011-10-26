require 'spec_helper'

include DelayedJobSpecHelper

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

  describe "#generate" do
    context "without timeout" do
      it "generates report without delay" do
        get :generate, :id => 'activity_overview'
        flash[:notice].should be_blank
        response.should be_redirect
      end
    end

    context "with timeout" do
      it "generates report without delay" do
        report = Factory(:report, :key => 'activity_overview', :data_request => @data_request)
        Report.stub(:find_or_initialize_by_key_and_data_request_id).and_return(report)
        report.should_receive(:generate_report).and_raise(Timeout::Error.new)

        get :generate, :id => 'activity_overview'
        response.should be_redirect
        flash[:notice].should == "We are generating your report and will send you email (at #{@admin.email}) when it is ready."

        run_delayed_jobs
        unread_emails_for(@admin.email).size.should == 1
        open_email(@admin.email).body.should include('We have generated "Activity Overview Report" report for you')
      end
    end
  end
end
