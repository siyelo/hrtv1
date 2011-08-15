class ClassificationsController < Reporter::BaseController
  include ClassificationsHelper
  include NumberHelper

  before_filter :load_activity_and_data_response
  before_filter :load_klasses, :only => [:edit, :update, :download_template, :bulk_create]
  before_filter :warn_if_not_classified, :only => [:edit]

  def edit
    @budget_coding_tree = CodingTree.new(@activity, @budget_klass)
    @spend_coding_tree  = CodingTree.new(@activity, @spend_klass)
    @budget_assignments = @budget_klass.with_activity(@activity).all.
                            map_to_hash{ |b| {b.code_id => b} }
    @spend_assignments  = @spend_klass.with_activity(@activity).all.
                            map_to_hash{ |b| {b.code_id => b} }

    # set default to 'my' view if there are code assignments present
    if params[:view].blank?
      params[:view] = @budget_coding_tree.roots.present? ? 'my' : 'all'
    end
  end

  def update
    unless (@activity.approved? || @activity.am_approved?)
      @budget_klass.update_classifications(@activity, params[:classifications][:budget])
      @spend_klass.update_classifications(@activity, params[:classifications][:spend])
      flash[:notice] = "Activity classification was successfully updated."
    end

    redirect_to edit_activity_classification_url(@activity, params[:id])
  end

  def derive_classifications_from_sub_implementers
    if @activity.derive_classifications_from_sub_implementers!(params[:coding_type])
      flash[:notice] = "District classifications were successfully derived from implementers."
    else
      flash[:error] = "We could not derive classification from implementers."
    end

    redirect_to edit_activity_classification_url(@activity, params[:id], :view => params[:view])
  end

  def bulk_create
    unless (@activity.approved? || @activity.am_approved?)
      begin
        if params[:file].present?
          doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
          CodeAssignment.create_from_file(doc, @activity, @budget_klass, @spend_klass)
          flash[:notice] = "Activity classification was successfully uploaded."
        else
          flash[:error] = 'Please select a file to upload classifications'
        end
      rescue FasterCSV::MalformedCSVError
        flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      end
    end

    redirect_to edit_activity_classification_url(@activity, params[:id], :view => params[:view])
  end

  def download_template
    code_klass = get_code_klass_for_classification_type(params[:id])
    template = CodeAssignment.download_template(code_klass)
    send_csv(template, "#{params[:id]}_template.csv")
  end

  private

    def load_activity_and_data_response
      unless current_user.admin?
        @activity = current_user.organization.dr_activities.find(params[:activity_id])
        @response = @activity.data_response
      else
        @activity = Activity.find(params[:activity_id])
        @response = @activity.data_response
      end
    end

    def get_coding_name(klass)
      case klass.to_s
      when 'CodingBudget'
        'Current Budget by Purposes'
      when 'CodingBudgetDistrict'
        'Current Budget by Locations'
      when 'CodingBudgetCostCategorization'
        'Current Budget by Inputs'
      when 'CodingSpend'
        'Past Expenditure by Purposes'
      when 'CodingSpendDistrict'
        'Past Expenditure by Locations'
      when 'CodingSpendCostCategorization'
        'Past Expenditure by Inputs'
      end
    end

    def load_data_response
      @response = @activity.data_response
    end

    def get_code_klass_for_classification_type(coding_type)
      case coding_type
      when 'purposes'
        Mtef
      when 'inputs'
        CostCategory
      when 'locations'
        Location
      end
    end

    def load_klasses
      @budget_klass, @spend_klass = case params[:id]
      when 'purposes'
        [CodingBudget, CodingSpend]
      when 'inputs'
        [CodingBudgetCostCategorization, CodingSpendCostCategorization]
      when 'locations'
        [CodingBudgetDistrict, CodingSpendDistrict]
      else
        raise "Invalid type #{params[:id]}".to_yaml
      end
    end

end
