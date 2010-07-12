class CodeAssignmentsController < ApplicationController

  def index
    #@projects = Projects.find_by_user(current_user)
    @activities = Activity.all
  end

  def manage
    @activity = Activity.find(params[:activity_id])
    #@activity = Activity.first
  end


  def update_assignments
    @activity = Activity.find(params[:activity_id])

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        flash[:notice] = 'Activity was successfully updated.'
        format.html { redirect_to(manage_code_assignments_path()) }
        format.xml  { head :ok }
      else
        format.html { render :action => "manage" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

end
