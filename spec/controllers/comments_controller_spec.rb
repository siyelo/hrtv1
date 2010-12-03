require File.dirname(__FILE__) + '/../spec_helper'

describe "Routing shortcuts for Comments (comments/1) should map" do
  controller_name :comments

  before(:each) do
    @comment = Factory.create(:comment)
    @comment.stub!(:to_param).and_return('1')
    @comments.stub!(:find).and_return(@comment)
  
    get :show, :id => "1"
  end
  
  it "comments_path to /comments" do
    comments_path.should == '/comments'
  end

  it "comment_path to /comments/1" do
    comment_path.should == '/comments/1'
  end
  
  it "comment_path(9) to /comments/9" do
    comment_path(9).should == '/comments/9'
  end

  it "edit_comment_path to /comments/1/edit" do
    edit_comment_path.should == '/comments/1/edit'
  end
  
  it "edit_comment_path(9) to /comments/9/edit" do
    edit_comment_path(9).should == '/comments/9/edit'
  end
  
  it "new_comment_path to /comments/new" do
    new_comment_path.should == '/comments/new'
  end
  
end


describe "Requesting Comment endpoints as visitor" do
  controller_name :comments

  context "RESTful routes" do
    context "Requesting /comments/ using GET" do
      before do get :index end
      it_should_behave_like "a protected endpoint"
    end 
  
    context "Requesting /comments/new using GET" do
      before do get :new end
      it_should_behave_like "a protected endpoint"
    end 
  
    context "Requesting /comments/1 using GET" do
      before do 
        @comment = Factory.create(:comment)
        get :show, :id => @comment.id
      end
      it_should_behave_like "a protected endpoint"
    end
  
    context "Requesting /comments using POST" do
      before do
        params = { :title => 'title', :comment => 'comment' }
        @comment = Factory.build(:comment, params )
        @comment.stub!(:save).and_return(true)
        post :create, :comment => params
      end
      it_should_behave_like "a protected endpoint"
    end
  
    context "Requesting /comments/1 using PUT" do
      before do
        params = { :title => 'title', :comment => 'comment' }
        @comment = Factory.create(:comment, params )
        @comment.stub!(:save).and_return(true)
        put :update, { :id => @comment.id }.merge(params)
      end
      it_should_behave_like "a protected endpoint"
    end
  
    context "Requesting /comments/1 using DELETE" do
      before do
        @comment = Factory.create(:comment)
        delete :destroy, :id => @comment.id
      end
      it_should_behave_like "a protected endpoint"
    end
  end
  
  context "ActiveScaffold" do
    context "GET methods" do
      before :each do
        @comment = Factory.create(:comment)
      end
  
      context "Requesting /comments/show_search using GET" do
        before do get :show_search, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end 
  
      context "Requesting /comments/edit_associated using GET" do
        before do get :edit_associated, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end
  
      context "Requesting /comments/new_existing using GET" do
        before do get :new_existing, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end 
  
      context "Requesting /comments/list using GET" do
        before do get :list, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end
  
      context "Requesting /comments/render_field using GET" do
        before do get :render_field, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /comments/1/row using GET" do
        before do get :row, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /comments/1/add_association using GET" do
        before do get :add_association, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /comments/1/edit_associated using GET" do
        before do get :edit_associated, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /comments/1/render_field using GET" do
        before do get :render_field, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /comments/1/nested using GET" do
        before do get :nested, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /comments/1/delete using GET" do
        before do get :delete, :id => @comment.id end
        it_should_behave_like "a protected endpoint"
      end
    end
  
    context "Requesting /comments/mark using PUT" do
      before do
        params = { :title => 'title', :comment => 'comment' }
        @comment = Factory.create(:comment, params )
        @comment.stub!(:save).and_return(true)
        put :mark, { :id => @comment.id }.merge(params)
      end
      it_should_behave_like "a protected endpoint"
    end
  
    context "Requesting /comments/add_existing_comments using POST" do
      before do
        params = { :title => 'title', :comment => 'comment' }
        @comment = Factory.build(:comment, params )
        @comment.stub!(:save).and_return(true)
        post :add_existing, :comment => params
      end
      it_should_behave_like "a protected endpoint"
    end    
    
    context "Requesting /comments/1/update_column using POST" do
      before do
        params = { :title => 'title', :comment => 'comment' }
        @comment = Factory.create(:comment, params )
        @comment.stub!(:save).and_return(true)
        post :update_column, :id => @comment.id, :resource => params
      end
      it_should_behave_like "a protected endpoint"
    end
    
    context "Requesting /comments/1/destroy_existing using DELETE" do
      before do
        @comment = Factory.create(:comment)
        delete :destroy_existing, :id => @comment.id
      end
      it_should_behave_like "a protected endpoint"
    end
  end
end


describe "Requesting Comment endpoints as a reporter" do
  controller_name :comments
  
  before :each do
    @user = Factory.create(:reporter)
    login @user
    #@comment = Factory.create(:comment, :user => @user)
    @comment = Factory.create(:comment) #TODO add back user!
    @user_comments.stub!(:find).and_return(@comment)
  end
  
  context "Requesting /comments/ using GET" do
    it "should find the user" do
      pending
      User.should_receive(:find).with(1).and_return(@user)
      get :index, :user_id => 1
    end

    it "should assign the found user for the view" do
      pending
      get :index, :user_id => 1
      assigns[:user].should == @user
    end
    
    it "should assign the user_comments association as the comments" do
      pending
      @user.should_receive(:comments).and_return(@user_comments)
      get :index, :user_id => 1
      assigns[:user_comments].should == @user_comments
    end
  end
  
  context "Requesting /comments/new using GET" do
    #before do get :new end
    it "should create a new comment for my user" do pending end
  end 

  context "Requesting /comments/1 using GET" do
    it "should get the comment if it belongs to me" do pending 
      @comment = Factory.create(:comment)
      get :show, :id => @comment.id
    end
    it "should not get the comment if it does not belong to me " do pending end
  end

  context "Requesting /comments using POST" do
    before do
      params = { :title => 'title', :comment => 'comment' }
      @comment = Factory.build(:comment, params )
      @comment.stub!(:save).and_return(true)
      post :create, :record => params
    end
    it "should create a new comment under my user" do pending end
  end

  context "Requesting /comments/1 using PUT" do
    before do
      params = { :title => 'title', :comment => 'comment' }
      @comment = Factory.create(:comment, params )
      @comment.stub!(:save).and_return(true)
      
    end
    it "should update the comment if it belongs to me" do 
        pending 
        put :update, :id => @comment.id, :record => params
    end
    it "should not update the comment if it does not belong to me " do 
      pending 
      put :update, :id => @comment.id, :record => params
    end
  end

  context "Requesting /comments/1 using DELETE" do
    before do
      @comment = Factory.create(:comment)
    end
    it "should delete the comment if it belongs to me" do 
      pending
      delete :destroy, :id => @comment.id
    end
    it "should not delete the comment if it does not belong to me " do 
      pending 
      delete :destroy, :id => @comment.id
    end
  end
end