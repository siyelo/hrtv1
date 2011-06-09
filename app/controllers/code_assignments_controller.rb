class CodeAssignmentsController < Reporter::BaseController
  include CodeAssignmentsHelper
  include NumberHelper

  before_filter :load_activity_and_data_response

  def show
    @coding_type         = params[:coding_type] || 'CodingBudget'
    @coding_class        = @coding_type.constantize
    @coding_tree         = CodingTree.new(@activity, @coding_class)
    @codes               = @coding_tree.root_codes
    @current_assignments = @coding_class.with_activity(@activity).all.map_to_hash{ |b| {b.code_id => b} }
    @error_message       = add_code_assignments_error(@coding_class, @activity)

    # set default to 'my' view if there are code assignments present
    if params[:view].blank?
      params[:view] = @current_assignments.present? ? 'my' : 'all'
    end
  end

  def update
    @coding_type   = params[:coding_type] || 'CodingBudget'
    @coding_class  = @coding_type.constantize
    CodeAssignment.update_classifications(@activity, params[:classifications], @coding_type)
    message = "Activity classification was successfully updated. Please check that you have completed all the other tabs if you have not already done so."
    @error_message = add_code_assignments_error(@coding_class, @activity)
    @error_message ? flash[:error] = @error_message : flash[:notice] = message
    redirect_to activity_code_assignments_url(@activity, :coding_type => params[:coding_type], :view => params[:view])
  end

  def copy_budget_to_spend
    if @activity.copy_budget_codings_to_spend([params[:coding_type]])
      flash[:notice] = "Current Budget classifications were successfully copied across."
    else
      flash[:error] = "We could not copy your current budget classifications across."
    end

    redirect_to activity_code_assignments_url(@activity, :coding_type => Activity::CLASSIFICATION_MAPPINGS[params[:coding_type]], :view => params[:view])
  end

  def derive_classifications_from_sub_implementers
    if @activity.derive_classifications_from_sub_implementers!(params[:coding_type])
      flash[:notice] = "District classifications were successfully derived from sub implementers."
    else
      flash[:error] = "We could not derive classification from sub implementers."
    end

    redirect_to activity_code_assignments_url(@activity, :coding_type => params[:coding_type], :view => params[:view])
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

    redirect_to activity_code_assignments_url(@activity, :coding_type => params[:coding_type], :view => params[:view])
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

    def add_code_assignments_error(coding_class, activity)
      if !activity_classified?(activity, coding_class)
        coding_type        = get_coding_type(coding_class)
        amount_name        = coding_type.to_s.capitalize == 'Spend' ? 'Past Expenditure' : coding_type.to_s.capitalize
        coding_type_amount = activity.send(coding_type) || 0
        coding_amount      = activity.send("#{coding_class}_amount")
        coding_amount      = 0 if coding_amount.nil?
        difference         = coding_type_amount - coding_amount
        percent_diff       = difference/coding_type_amount * 100
        coding_type_amount = n2c(coding_type_amount)
        coding_amount      = n2c(coding_amount)
        difference         = n2c(difference)
        percent_diff       = n2c(percent_diff)
        classification_name = get_coding_name(coding_class)

        if coding_amount != coding_type_amount
          return "We're sorry, when we added up your #{classification_name}
           classifications, they equaled #{coding_amount} but the #{amount_name}
           is #{coding_type_amount} (#{coding_type_amount} - #{coding_amount}
           = #{difference}, which is ~#{percent_diff}%). The total classified
           should add up to #{coding_type_amount}. Your #{classification_name} classifications must be entered and the total must be equal to the #{amount_name} amount."

        end
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
      when 'ServiceLevelBudget'
        'Current Budget by Service Level'
      when 'CodingSpend'
        'Past Expenditure by Purposes'
      when 'CodingSpendDistrict'
        'Past Expenditure by Locations'
      when 'CodingSpendCostCategorization'
        'Past Expenditure by Inputs'
      when 'ServiceLevelSpend'
        'Past Expenditure by Service Level'
      end
    end

    def activity_classified?(activity, klass)
      case klass.to_s
      when 'CodingBudget'
        activity.coding_budget_classified?
      when 'CodingBudgetDistrict'
        activity.coding_budget_district_classified?
      when 'CodingBudgetCostCategorization'
        activity.coding_budget_cc_classified?
      when 'ServiceLevelBudget'
        activity.service_level_budget_classified?
      when 'CodingSpend'
        activity.coding_spend_classified?
      when 'CodingSpendDistrict'
        activity.coding_spend_district_classified?
      when 'CodingSpendCostCategorization'
        activity.coding_spend_cc_classified?
      when 'ServiceLevelSpend'
        activity.service_level_spend_classified?
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
      when 'ServiceLevelBudget', 'ServiceLevelSpend'
        [ServiceLevel, 'service_levels']
      end
    end
end
