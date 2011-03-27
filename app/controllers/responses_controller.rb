class ResponsesController < ApplicationController
  layout 'reporter' #TODO: separate reporter/admin actions
  before_filter :require_user
  before_filter :find_response, :only => [:edit, :update, :review, :submit]
  before_filter :find_help, :only => [:edit, :update, :review]
  before_filter :find_review_status, :only => [:review, :submit]
  before_filter :find_requests, :only => [:new, :create, :edit]

  def new
    @data_response = DataResponse.new
  end

  def show
    if current_user.admin?
      @data_response = DataResponse.find(params[:id])
    else
      @data_response = current_user.data_responses.find(params[:id])
    end
    @projects                    = @data_response.projects.find(:all, :order => "name ASC")
    @activities_without_projects = @data_response.activities.roots.without_a_project
    @code_roots                  = Code.for_activities.roots
    @cost_cat_roots              = CostCategory.roots
    @other_cost_roots            = OtherCostCode.roots
    @policy_maker                = true #view helper
  end

  # POST /data_responses
  def create
    @data_response  = DataResponse.new(params[:data_response])
    @data_response.organization = current_user.organization

    respond_to do |format|
      if @data_response.save
        flash[:notice] = "Your response was successfully created. You can edit your preferences on the Settings tab."
        format.html { redirect_to response_projects_path(@data_response) }
      else
        format.html { render :action => :new }
      end
    end
  end

  def edit
    current_user.current_data_response = @data_response
    current_user.save
  end

  def update
    @data_response.update_attributes params[:data_response]
    if @data_response.save
      flash[:notice] = "Successfully updated."
      redirect_to edit_response_url(@data_response)
    else
      render :action => :edit
    end
  end

  def review
  end

  def submit
    if @uncoded_activities.empty? && @uncoded_other_costs.empty?
      @data_response.submitted = true
      @data_response.submitted_at = Time.now
      @data_response.save
      flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
      redirect_to review_response_url(@data_response)
    else
      flash[:error] = "You cannot submit unless you have coded all your activities and other costs."
      redirect_to review_response_url(@data_response)
    end
  end

  protected

    def find_response
      @data_response = DataResponse.available_to(current_user).find params[:id]
    end

    def find_requests
      @requests = DataRequest.all
    end

    def find_help
      @model_help = ModelHelp.find_by_model_name 'DataResponseReview'
    end

    def find_review_status
      @data_response || find_response
      root_activities         = @data_response.activities.roots
      other_cost_activities   = @data_response.activities.with_type("OtherCost")
      @uncoded_activities     = root_activities.reject{ |a| a.classified? || (a.budget_classified? && !a.spend_classified?)  }
      @uncoded_other_costs    = other_cost_activities.reject{ |a| a.classified? || (a.budget_classified? && !a.spend_classified?)}
      @budget_activities      = root_activities.select{ |a| a.budget_classified? && !a.spend_classified? }
      @budget_other_costs     = other_cost_activities.select{ |a| a.budget_classified? && !a.spend_classified? }
      @warnings               = []
      @warnings               << :other_costs_missing if other_cost_activities.empty?
      @warnings               << :activities_missing  if root_activities.empty?
    end

end
