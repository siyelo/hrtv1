class Admin::ResponsesController < Admin::BaseController

  before_filter :load_counters, :only => [:index, :in_progress, :empty, :submitted]

  def index
    find_submitted
  end

  def in_progress
    find_in_progress
  end

  def empty
    find_empty
  end

  def submitted
    find_submitted
    render :index
  end

  def show
    @response                     = DataResponse.find(params[:id])
    @projects                     = @response.projects.find(:all, :order => "name ASC")
    @activities_without_projects  = @response.activities.roots.without_a_project
    @other_costs_without_projects = @response.other_costs.without_a_project
    @code_roots                   = Code.purposes.roots
    @cost_cat_roots               = CostCategory.roots
    @other_cost_roots             = OtherCostCode.roots
  end

  def destroy
    @response = DataResponse.find(params[:id])

    respond_to do |format|
      if @response.empty?
        @response.destroy
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
    @response = DataResponse.find(params[:id])
  end

  protected

    def find_submitted
      @submitted_responses ||= DataResponse.submitted.find(:all, :include => :organization)
    end

    def find_in_progress
      @in_progress_responses ||= DataResponse.in_progress
    end

    def find_empty
      @empty_responses ||= DataResponse.empty
    end

    def load_counters
      @submitted_total = find_submitted.count
      @in_progress_total = find_in_progress.count
      @empty_total = find_empty.count
    end
end
