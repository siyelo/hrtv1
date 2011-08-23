class ClassificationsController < Reporter::BaseController
  include ClassificationsHelper
  include NumberHelper

  before_filter :load_activity_and_data_response
  before_filter :load_klasses_from_mode, :only => [:download_template, :bulk_create]

  def derive_classifications_from_sub_implementers
    if @activity.derive_classifications_from_sub_implementers!(params[:coding_type])
      flash[:notice] = "District classifications were successfully derived from implementers."
    else
      flash[:error] = "We could not derive classification from implementers."
    end

    redirect_to edit_activity_or_ocost_path(@activity, :mode => params[:mode], :view => params[:view])
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

    redirect_to edit_activity_or_ocost_path(@activity, :mode => params[:mode], :view => params[:view])
  end

  def download_template
    code_klass = get_code_klass_for_classification_type(params[:mode])
    template = CodeAssignment.download_template(code_klass)
    send_csv(template, "#{params[:mode]}_template.csv")
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
end
