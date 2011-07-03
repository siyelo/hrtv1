require 'spec_helper'

describe Admin::OrganizationsController do
  before :each do
    login_as_admin
  end

  describe "show organization" do
    before :each do
      @mock_object = mock_model(Organization)
      Organization.stub!(:find).with("1").and_return(@mock_object)
    end

    it "finds organization" do
      Organization.should_receive(:find).with("1").and_return(@mock_object)
      get :show, :id => "1"
    end
  end

  describe "destroy organization" do
    context "when organization is empty" do
      before :each do
        @mock_object = mock_model(Organization,
                                  :is_empty? => true,
                                  :to_label => 'org label',
                                  :destroy => true)
        Organization.stub!(:find).with("1").and_return(@mock_object)
      end

      it "finds organization" do
        Organization.should_receive(:find).with("1").and_return(@mock_object)
        delete :destroy, :id => "1"
      end

      it "destroys organization" do
        @mock_object.should_receive(:destroy).and_return(true)
        delete :destroy, :id => "1"
      end

      context 'html format' do
        it "sets flash notice" do
          delete :destroy, :id => "1"
          flash[:notice].should == "Organization was successfully deleted."
        end

        it "redirects to the duplicate_admin_organizations_path" do
          request.env['HTTP_REFERER'] = 'http://localhost:3000/admin/organizations/duplicate'
          delete :destroy, :id => "1"
          response.should redirect_to(duplicate_admin_organizations_path)
        end
      end

      context 'js format' do
        it "returns proper json" do
          delete :destroy, :id => "1", :format => "js"
          response.body.should == '{"message":"Organization was successfully deleted."}'
        end

        it "does not redirect" do
          delete :destroy, :id => "1", :format => "js"
          response.should_not be_redirect
        end
      end
    end


    context "when organization is not empty" do
      before :each do
        @mock_object = mock_model(Organization,
                                  :is_empty? => false,
                                  :to_label => 'org label',
                                  :destroy => true)
        Organization.stub!(:find).with("1").and_return(@mock_object)
      end

      it "finds organization" do
        Organization.should_receive(:find).with("1").and_return(@mock_object)
        delete :destroy, :id => "1"
      end

      it "does not destroys organization" do
        @mock_object.should_not_receive(:destroy)
        delete :destroy, :id => "1"
      end

      context 'html format' do
        it "sets flash notice" do
          delete :destroy, :id => "1"
          flash[:error].should == "You cannot delete an organization that has users or data associated with it."
        end

        it "redirects to the duplicate_admin_organizations_path" do
          request.env['HTTP_REFERER'] = 'http://localhost:3000/admin/organizations/duplicate'
          delete :destroy, :id => "1"
          response.should redirect_to(duplicate_admin_organizations_path)
        end
      end

      context 'js format' do
        it "returns proper json when request is with js format" do
          delete :destroy, :id => "1", :format => "js"
          response.body.should == '{"message":"You cannot delete an organization that has users or data associated with it."}'
        end

        it "does not redirects" do
          delete :destroy, :id => "1", :format => "js"
          response.should_not be_redirect
        end

        it "sets status to :partial_content" do
          delete :destroy, :id => "1", :format => "js"
          response.status.should == "206 Partial Content"
        end
      end
    end
  end

  describe "duplicate organization" do
    before :each do
      organizations = [mock_model(Organization)]
      Organization.stub_chain(:without_users, :ordered).and_return(organizations)
      Organization.stub!(:ordered).and_return(organizations)
    end

    it "assigns variables" do
      Organization.should_receive(:without_users)
      Organization.should_receive(:ordered)
      get :duplicate
      assigns(:organizations_without_users).should_not be_nil
      assigns(:all_organizations).should_not be_nil
    end

    it "renders duplicate template" do
      get :duplicate
      response.should render_template('admin/organizations/duplicate')
    end
  end

  describe "remove duplicate organization" do
    context "duplicate_organization_id and target_organization_id are blank" do
      context 'html format' do
        it "redirects to the duplicate_admin_organizations_path" do
          put :remove_duplicate
          response.should redirect_to(duplicate_admin_organizations_path)
        end

        it "sets flash error" do
          put :remove_duplicate
          flash[:error].should == "Duplicate or target organizations not selected."
        end
      end

      context 'js format' do
        it "returns proper json" do
          put :remove_duplicate, :format => 'js'
          response.body.should == '{"message":"Duplicate or target organizations not selected."}'
        end

        it "does not redirect" do
          put :remove_duplicate, :format => 'js'
          response.should_not be_redirect
        end

        it "sets status to :partial_content" do
          put :remove_duplicate, :format => 'js'
          response.status.should == "206 Partial Content"
        end
      end
    end

    context "duplicate_organization_id and target_organization_id have same value" do
      context 'html format' do
        it "redirects to the duplicate_admin_organizations_path" do
          put :remove_duplicate, :duplicate_organization_id => 1, :target_organization_id => 1
          response.should redirect_to(duplicate_admin_organizations_path)
        end

        it "sets flash error" do
          put :remove_duplicate, :duplicate_organization_id => 1, :target_organization_id => 1
          flash[:error].should == "Same organizations for duplicate and target selected."
        end
      end

      context 'js format' do
        it "returns proper json" do
          put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 1
          response.body.should == '{"message":"Same organizations for duplicate and target selected."}'
        end

        it "does not redirect" do
          put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 1
          response.should_not be_redirect
        end

        it "sets status to :partial_content" do
          put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 1
          response.status.should == "206 Partial Content"
        end
      end
    end

    context "duplicate organization has users" do
      before :each do
        Organization.stub!(:find).with("1").and_return(@org1 = mock_model(Organization))
        Organization.stub!(:find).with("2").and_return(@org2 = mock_model(Organization))
        @org1.stub!(:name).and_return('org1')
        @org1.stub_chain(:users, :size).and_return(1)
      end

      context 'html format' do
        it "redirects to the duplicate_admin_organizations_path" do
          put :remove_duplicate, :duplicate_organization_id => 1, :target_organization_id => 2
          response.should redirect_to(duplicate_admin_organizations_path)
        end

        it "sets flash error" do
          put :remove_duplicate, :duplicate_organization_id => 1, :target_organization_id => 2
          flash[:error].should == "Duplicate organization org1 has users."
        end
      end

      context 'js format' do
        it "returns proper json" do
          put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 2
          response.body.should == '{"message":"Duplicate organization org1 has users."}'
        end

        it "does not redirect" do
          put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 2
          response.should_not be_redirect
        end

        it "sets status to :partial_content" do
          put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 2
          response.status.should == "206 Partial Content"
        end
      end
    end

    context "merge organizations" do
      before :each do
        Organization.stub!(:find).with("1").and_return(@org1 = mock_model(Organization))
        Organization.stub!(:find).with("2").and_return(@org2 = mock_model(Organization))
        Organization.stub!(:"merge_organizations!").with(@org2, @org1).and_return(true)
        @org1.stub!(:users).and_return(users = mock('users'))
        users.stub!(:size).and_return(0)
      end

      context 'html format' do
        it "redirects to the duplicate_admin_organizations_path" do
          put :remove_duplicate, :duplicate_organization_id => 1, :target_organization_id => 2
          response.should redirect_to(duplicate_admin_organizations_path)
        end

        it "sets flash error" do
          put :remove_duplicate, :duplicate_organization_id => 1, :target_organization_id => 2
          flash[:notice].should == "Organizations successfully merged."
        end
      end

      context 'js format' do
        it "returns proper json" do
          put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 2
          response.body.should == '{"message":"Organizations successfully merged."}'
        end

        it "does not redirect" do
          put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 2
          response.should_not be_redirect
        end

        it "sets status to :partial_content" do
          put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 2
          response.status.should == "200 OK"
        end
      end
    end
  end
end
