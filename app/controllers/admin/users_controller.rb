class Admin::UsersController < UsersController
  def create
    if current_user.sysadmin?
      check_for_new_organization(params[:user], :organization_id)
      @user = User.new(params[:user])
      create_and_respond
            #
            # respond_to do |format|
            #   format.html { create!(:notice => "User was successfully created.") {
            #     member_collection_url } }
            #   format.json {
            #     check_for_new_organization(params[:user], :organization_id)
            #     @user = User.new(params[:user])
            #     @user.valid? # trigger validation errors
            #     if @user.only_password_errors?
            #       @user.save_and_invite(current_user)
            #       render :json => {:status => 'ok',
            #                        :row => render_to_string(:partial => "row.html.haml",
            #                                                  :locals => {:user => @user}),
            #                        :form => render_to_string(:partial => "inline_form.html.haml",
            #                                                  :locals => {:user => User.new}),
            #                        :message => "An email invitation has been sent to '#{@user.name}' to join '#{@user.organization.name}'"}
            #     else
            #       #raise @user.errors.full_messages.to_yaml
            #       render :json => {:status => 'error',
            #                        :form => render_to_string(:partial => "inline_form.html.haml",
            #                                                  :locals => {:user => @user})}
            #     end
            #   }
            # end
    end
  end

  protected
    def member_collection_url
      admin_users_url
    end
end
