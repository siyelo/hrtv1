class ClassificationsController < Reporter::BaseController
  include ClassificationsHelper
  include NumberHelper

  before_filter :load_activity_and_data_response
  before_filter :load_klasses, :only => [:edit, :update]

  def edit
    @budget_coding_tree = CodingTree.new(@activity, @budget_klass)
    @spend_coding_tree  = CodingTree.new(@activity, @spend_klass)
    @budget_assignments = @budget_klass.with_activity(@activity).all.
                            map_to_hash{ |b| {b.code_id => b} }
    @spend_assignments  = @spend_klass.with_activity(@activity).all.
                            map_to_hash{ |b| {b.code_id => b} }

    set_classification_errors

    # set default to 'my' view if there are code assignments present
    if params[:view].blank?
      params[:view] = @budget_coding_tree.roots.present? ? 'my' : 'all'
    end
  end

  def update
    @budget_klass.update_classifications(@activity, params[:classifications][:budget])
    @spend_klass.update_classifications(@activity, params[:classifications][:spend])

    set_classification_errors
    flash[:notice] = "Activity classification was successfully updated."
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
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        CodeAssignment.create_from_file(doc, @activity, params[:coding_type])
        flash[:notice] = "Activity classification was successfully uploaded."
      else
        flash[:error] = 'Please select a file to upload classifications'
      end
    rescue FasterCSV::MalformedCSVError
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
    end

    redirect_to edit_activity_classification_url(@activity, params[:id], :view => params[:view])
  end

  def download_template
    klass, name = get_klass_and_name_from_coding_type(params[:coding_type])
    template = CodeAssignment.download_template(klass)
    send_csv(template, "#{name}_template.csv")
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

    def get_klass_and_name_from_coding_type(coding_type)
      case coding_type
      when 'CodingBudget', 'CodingSpend'
        [Mtef, 'purposes']
      when 'CodingBudgetDistrict', 'CodingSpendDistrict'
        [Location, 'locations']
      when 'CodingBudgetCostCategorization', 'CodingSpendCostCategorization'
        [CostCategory, 'inputs']
      end
    end

    def load_klasses
      @budget_klass, @spend_klass = case params[:id]
      when 'purposes'
        [CodingBudget, CodingSpend]
      when 'inputs'
        [CodingBudgetCostCategorization, CodingSpendCostCategorization]
      else
        raise "Invalid type #{params[:id]}".to_yaml
      end
    end

    def set_classification_errors
      errors = @activity.classification_errors_by_type(params[:id])
      flash[:error] = errors.join(" and ") if errors.present?
    end
end
