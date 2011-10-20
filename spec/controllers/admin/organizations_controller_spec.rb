require 'spec_helper'

describe Admin::OrganizationsController do
  before :each do
    login_as_admin
  end

  describe "index" do
    before :each do
      @request1 = Factory(:data_request)
      @admin.set_current_response_to_latest!
      @organization = Factory(:organization)
      @data_response = @organization.responses.find_by_data_request_id(@request1.id)
      @all_organizations = [@admin.organization, @request1.organization, @organization]
    end

    it "should return all organizations when not using any filter" do
      get :index
      assigns(:organizations).should == @all_organizations
    end

    it "should return all organizations when using All filter" do
      get :index, :filter => 'All'
      assigns(:organizations).should == @all_organizations
    end

    it "should ignore unrecognized filters" do
      get :index, :filter => 'Blah'
      assigns(:organizations).should == @all_organizations
    end

    it "should filter by empty response" do
      get :index, :filter => 'Not Started'
      assigns(:organizations).should == @all_organizations
    end

    it "should filter by started response" do
      @data_response.state = 'started'
      @data_response.save!
      get :index, :filter => 'Started'
      assigns(:organizations).should == [@organization]
    end

    it "should filter by rejected response" do
      @data_response.state = 'rejected'
      @data_response.save!
      get :index, :filter => 'Rejected'
      assigns(:organizations).should == [@organization]
    end

    it "should filter by submitted response" do
      @data_response.state = 'submitted'
      @data_response.save!
      get :index, :filter => 'Submitted'
      assigns(:organizations).should == [@organization]
    end

    it "should filter by complete response" do
      @data_response.state = 'accepted'
      @data_response.save!
      get :index, :filter => 'Accepted'
      assigns(:organizations).should == [@organization]
    end

    it "should filter by reporting" do
      get :index, :filter => 'Reporting'
      assigns(:organizations).should == @all_organizations
    end

    it "should filter by non-reporting" do
      get :index, :filter => 'Non-Reporting'
      assigns(:organizations).should == []
    end

    it "should display all organizations" do
      organization1 = Factory.build(:organization, :raw_type => '')
      organization1.save(false)

      get :index, :filter => 'All'
      assigns(:organizations).size.should == @all_organizations.size + 1
    end
  end

  describe "show organization" do
    it "finds organization" do
      @organization = Factory(:organization)
      get :show, :id => @organization.id
      assigns(:organization).should_not be_nil
    end
  end

  describe "destroy organization" do
    context "when organization has data, but no external references" do
      before :each do
        basic_setup_implementer_split_for_controller
        other_org    = Factory(:organization)
        @data_request.organization = other_org #the old switcheroo
        @data_request.save
        @data_response.submit!
        @organization.stub!(:to_label).and_return('org label')
        @organization.stub!(:destroy).and_return(true)
      end

      it "sets flash notice" do
        delete :destroy, :id => @organization.id
        flash[:notice].should == "Organization was successfully destroyed."
      end

      it "redirects to the duplicate_admin_organizations_path" do
        request.env['HTTP_REFERER'] = 'http://localhost:3000/admin/organizations/duplicate'
        delete :destroy, :id => @organization.id
        response.should redirect_to(duplicate_admin_organizations_path)
      end

      it "returns proper json" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.body.should == '{"message":"Organization was successfully destroyed."}'
      end

      it "does not js redirect" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.should_not be_redirect
      end
    end


    context "when organization has references" do
      before :each do
        basic_setup_implementer_split_for_controller #will have a data_request
        @organization.stub!(:to_label).and_return('org label')
        @organization.stub!(:destroy).and_return(true)
      end

      it "sets flash notice" do
        delete :destroy, :id => @organization.id
        flash[:error].should == "You cannot delete an organization that has (external) data referencing it."
      end

      it "redirects to the duplicate_admin_organizations_path" do
        request.env['HTTP_REFERER'] = 'http://localhost:3000/admin/organizations/duplicate'
        delete :destroy, :id => @organization.id
        response.should redirect_to(duplicate_admin_organizations_path)
      end

      it "returns proper json when request is with js format" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.body.should == '{"message":"You cannot delete an organization that has (external) data referencing it."}'
      end

      it "does not redirect with js" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.should_not be_redirect
      end

      it "sets status to :partial_content with js" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.status.should == "206 Partial Content"
      end
    end
  end

  describe "duplicate organization" do
    before :each do
      @organization = Factory(:organization)
      organizations = [@organization]
      Organization.stub_chain(:ordered).and_return(organizations)
      Organization.stub!(:ordered).and_return(organizations)
    end

    it "assigns variables" do
      Organization.should_receive(:ordered)
      get :duplicate
      assigns(:all_organizations).should_not be_nil
    end

    it "renders duplicate template" do
      get :duplicate
      response.should render_template('admin/organizations/duplicate')
    end
  end

  describe "remove duplicate organization" do
    context "duplicate_organization_id and target_organization_id are blank" do
      it "redirects to the duplicate_admin_organizations_path" do
        put :remove_duplicate
        response.should redirect_to(duplicate_admin_organizations_path)
      end

      it "sets flash error" do
        put :remove_duplicate
        flash[:error].should == "Duplicate or target organizations not selected."
      end

      it "returns proper json" do
        put :remove_duplicate, :format => 'js'
        response.body.should == '{"message":"Duplicate or target organizations not selected."}'
      end

      it "does not redirect" do
        put :remove_duplicate, :format => 'js'
        response.should_not be_redirect
      end

      it "responds with status :partial_content (json)" do
        put :remove_duplicate, :format => 'js'
        response.status.should == "206 Partial Content"
      end
    end

    context "duplicate_organization_id and target_organization_id have same value" do
      it "redirects to the duplicate_admin_organizations_path" do
        put :remove_duplicate, :duplicate_organization_id => 1, :target_organization_id => 1
        response.should redirect_to(duplicate_admin_organizations_path)
      end

      it "sets flash error" do
        put :remove_duplicate, :duplicate_organization_id => 1, :target_organization_id => 1
        flash[:error].should == "Same organizations for duplicate and target selected."
      end

      it "returns proper json" do
        put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 1
        response.body.should == '{"message":"Same organizations for duplicate and target selected."}'
      end

      it "does not redirect" do
        put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 1
        response.should_not be_redirect
      end

      it "responds with status :partial_content (json)" do
        put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 1
        response.status.should == "206 Partial Content"
      end
    end

    context "duplicate organization has users" do
      before :each do
        @org1 = Factory(:organization, :name => 'org1')
        @org2 = Factory(:organization)
        Factory(:reporter, :organization => @org1)
      end

      it "redirects to the duplicate_admin_organizations_path" do
        put :remove_duplicate, :duplicate_organization_id => @org1.id, :target_organization_id => @org2.id
        response.should redirect_to(duplicate_admin_organizations_path)
        flash[:notice].should == "Organizations successfully merged."
      end

      it "responds OK (json)" do
        put :remove_duplicate, :format => 'js', :duplicate_organization_id => @org1, :target_organization_id => @org2
        response.body.should == '{"message":"Organizations successfully merged."}'
        response.should_not be_redirect
        response.status.should == "200 OK"
      end
    end

    context "merge organizations" do
      before :each do
        @org1 = Factory(:organization, :name => 'org1')
        @org2 = Factory(:organization)
        Organization.stub!(:"merge_organizations!").with(@org2, @org1).and_return(true)
      end

      it "redirects to the duplicate_admin_organizations_path" do
        put :remove_duplicate, :duplicate_organization_id => @org1.id, :target_organization_id => @org2.id
        response.should redirect_to(duplicate_admin_organizations_path)
        flash[:notice].should == "Organizations successfully merged."
      end

      it "responds OK (json)" do
        put :remove_duplicate, :format => 'js', :duplicate_organization_id => @org1, :target_organization_id => @org2
        response.body.should == '{"message":"Organizations successfully merged."}'
        response.should_not be_redirect
        response.status.should == "200 OK"
      end
    end
  end
end
