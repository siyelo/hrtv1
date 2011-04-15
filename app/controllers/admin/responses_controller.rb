class Admin::ResponsesController < Admin::BaseController

  def index
    self.find_submitted
  end

  def in_progress
    @in_progress_responses = DataResponse.available_to(current_user).in_progress
  end

  def empty
    @empty_responses       = DataResponse.available_to(current_user).empty
  end

  def submitted
    self.find_submitted
    render :index
  end

  def show
    @data_response               = DataResponse.find(params[:id])
    @projects                    = @data_response.projects.find(:all, :order => "name ASC")
    @activities_without_projects = @data_response.activities.roots.without_a_project
    @code_roots                  = Code.purposes.roots
    @cost_cat_roots              = CostCategory.roots
    @other_cost_roots            = OtherCostCode.roots
  end

  def destroy
    @data_response = DataResponse.find(params[:id])

    respond_to do |format|
      if @data_response.empty?
        @data_response.destroy
        format.html do
          flash[:notice] = "Data response was successfully deleted."
          redirect_to admin_responses_url
        end
      else
        format.html do
          flash[:error] = "Data response is not empty."
          redirect_to admin_responses_url
        end
      end
      format.js   { render :nothing => true }
    end
  end

  def delete
    @data_response = DataResponse.find(params[:id])
  end

  protected

    def find_submitted
      @submitted_responses   = DataResponse.available_to(current_user).submitted.find(:all, :include => :organization)
    end
end
