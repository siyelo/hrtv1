require 'set'
class ActivitiesController < Reporter::BaseController
  SORTABLE_COLUMNS = ['projects.name', 'description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  before_filter :confirm_activity_type, :only => [:edit]
  belongs_to :data_response, :route_name => 'response', :instance_name => 'response'

  def index
    scope = @response.activities.roots.scoped({:include => :project})
    scope = scope.scoped(:conditions => ["UPPER(projects.name) LIKE UPPER(:q) OR
                                          UPPER(activities.name) LIKE UPPER(:q) OR
                                          UPPER(activities.description) LIKE UPPER(:q)",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @activities = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def new
    @activity = Activity.new
    @activity.project = @response.projects.find_by_id(params[:project_id])
    @activity.provider = current_user.organization
    respond_to do |format|
      format.html
      format.json { render :json => {:html => render_to_string(:partial => 'new_inline.html.haml') } }
    end
  end

  def edit
    load_comment_resources(resource)
    edit!
  end

  def create
    clean_out_sa_params(params)
    @activity = @response.activities.new(params[:activity])

    if @activity.save
      respond_to do |format|
        format.html { 
          flash[:notice] = 'Activity was successfully created' 
          # redirect_to edit_response_workplan_path(@response, :spend)
          html_redirect
        }
        format.js   { js_redirect }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js   { js_redirect }
      end
    end
  end

  def update
    clean_out_sa_params(params)
    check_for_new_provider(params)
    @activity = Activity.find(params[:id])
    if @activity.update_attributes(params[:activity])
      respond_to do |format|
        format.html do
          if @activity.check_projects_budget_and_spend?
            flash[:notice] = 'Activity was successfully updated'
          else
            flash[:error] = 'Please be aware that your activities spend/budget exceeds that of your projects'
          end
          # redirect_to edit_response_workplan_path(@response, :spend)
          html_redirect
        end
        format.js   { js_redirect }
      end
    else
      respond_to do |format|
        format.html { load_comment_resources(resource); render :action => 'edit'}
        format.js   { js_redirect }
      end
    end
  end

  def show
    load_comment_resources(resource)
    show!
  end

  # called only via Ajax
  def approve
    if current_user.admin? || current_user.activity_manager?
      @activity = @response.activities.find(params[:id])
      @activity.update_attributes({:approved => params[:checked]})
      render :nothing => true
    else
      raise AccessDenied
    end
  end

  # TODO refactor
  def classifications
    activity = Activity.find(params[:id])
    other_costs = params[:other_costs] == '1' ? true : false
    code_roots =  other_costs ? OtherCostCode.roots : Code.purposes.roots
    render :partial => '/shared/data_responses/classifications', :locals => {:activity => activity, :other_costs => other_costs, :cost_cat_roots => CostCategory.roots, :code_roots => (other_costs ? OtherCostCode.roots : Code.purposes.roots), :service_level_roots => ServiceLevel.roots}
  end

  def project_sub_form
    @activity = @response.activities.find_by_id(params[:activity_id])
    @project  = @response.projects.find(params[:project_id])
    render :partial => "project_sub_form",
           :locals => {:activity => (@activity || :activity), :project => @project}
  end

  def template
    template = Activity.download_template
    send_csv(template, 'activities_template.csv')
  end

  def export
    activities = params[:project_id].present? ?
      @response.projects.find(params[:project_id]).activities : @response.activities
    template = Activity.download_template(activities)
    send_csv(template, 'activities_existing.csv')
  end

  def bulk_create
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        @activities = Activity.find_or_initialize_from_file(@response, doc, params[:project_id])
      else
        flash[:error] = 'Please select a file to upload activities'
        redirect_to response_projects_path(@response)
      end
    rescue FasterCSV::MalformedCSVError
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to response_projects_path(@response)
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        if request.referrer.match('workplan')
          redirect_to response_workplans_path(@response)
        else
          redirect_to response_projects_url(@response)
        end
      end
    end
  end

  private

    def clean_out_sa_params(params)
      unless params[:activity][:sub_activities_attributes].nil?
        params[:activity][:sub_activities_attributes].each_key do |key|
          if params[:activity][:sub_activities_attributes][key][:spend].last == '%'
            if params[:activity][:sub_activities_attributes][key][:spend].to_i < 101
              spend = params[:activity][:spend].to_f * params[:activity][:sub_activities_attributes][key][:spend].delete('%').to_f / 100
              params[:activity][:sub_activities_attributes][key][:spend] = spend
            else
              spend = params[:activity][:sub_activities_attributes][key][:spend].delete('%')
              params[:activity][:sub_activities_attributes][key][:spend] = spend
            end
          end
          if params[:activity][:sub_activities_attributes][key][:budget].last == '%'
            if params[:activity][:sub_activities_attributes][key][:budget].to_i < 101
              budget = params[:activity][:budget].to_f * params[:activity][:sub_activities_attributes][key][:budget].delete('%').to_f / 100
              params[:activity][:sub_activities_attributes][key][:budget] = budget
            else
              budget = params[:activity][:sub_activities_attributes][key][:budget].delete('%')
              params[:activity][:sub_activities_attributes][key][:budget] = budget
            end
          end
        end
      end
    end

    def check_for_new_provider(params)
      unless params[:activity][:provider_id].nil?
        unless is_number?(params[:activity][:provider_id])
          name = params[:activity][:provider_id]
          params[:activity][:provider] = {}
          params[:activity][:provider][:name] = name
          params[:activity].delete(:provider_id)
        end
      end
    end

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "projects.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def html_redirect
      if params[:commit] == "Save & Classify >"
        coding_type = @response.data_request.spend? ? 'spend' : 'budget'
        redirect_to edit_response_workplan_path(@response, coding_type)
      else
        redirect_to response_projects_path(@activity.project.response)
      end
    end

    def js_redirect
      if request.referrer.match('workplan')
        if @activity.valid?
          render :json => {:status => @activity.valid?,
                           :html => render_to_string({:partial => 'workplans/activity_row',
                                                :locals => {:activity => @activity,
                                                            :type => params[:type]}})}
        else
          render :json => {:status => @activity.valid?,
                           :html => render_to_string({:partial => 'new_inline',
                                                :locals => {:activity => @activity,
                                                            :type => params[:type]}})}
        end
      else
        render :partial => 'bulk_edit', :layout => false,
          :locals => {:activity => @activity, :response => @response}
      end
    end

    def confirm_activity_type
      @activity = Activity.find(params[:id])     
      return redirect_to edit_response_other_cost_path(@response, @activity) if @activity.class.eql? OtherCost
      return redirect_to edit_response_activity_path(@response, @activity.activity) if @activity.class.eql? SubActivity
    end

end
