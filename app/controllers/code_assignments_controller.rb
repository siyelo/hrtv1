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
  end

  def update
    @coding_type   = params[:coding_type] || 'CodingBudget'
    @coding_class  = @coding_type.constantize
    if params[:activity].present? && params[:activity][:updates].present?
      @coding_class.update_codings(params[:activity][:updates], @activity)
      message = "Activity classification was successfully updated. Please check that you have completed all the other tabs if you have not already done so."
    end
    @error_message = add_code_assignments_error(@coding_class, @activity)
    @error_message ? flash[:error] = @error_message : flash[:notice] = message
    redirect_to activity_code_assignments_url(@activity, :coding_type => params[:coding_type])
  end

  def copy_budget_to_spend
    if @activity.copy_budget_codings_to_spend([params[:coding_type]])
      flash[:notice] = "Budget classifications were successfully copied across."
    else
      flash[:error] = "We could not copy your budget classifications across."
    end

    redirect_to activity_code_assignments_url(@activity, :coding_type => Activity::CLASSIFICATION_MAPPINGS[params[:coding_type]])
  end

  def derive_classifications_from_sub_implementers
    if @activity.derive_classifications_from_sub_implementers!(params[:coding_type])
      flash[:notice] = "District classifications were successfully derived from sub implementers."
    else
      flash[:error] = "We could not derive classification from sub implementers."
    end
      redirect_to activity_code_assignments_url(@activity, :coding_type => params[:coding_type])
  end

  private

    def load_activity_and_data_response
      unless current_user.admin?
        @activity = current_user.organization.dr_activities.find(params[:activity_id])
        @data_response = @activity.data_response
      else
        @activity = Activity.find(params[:activity_id])
        @data_response = @activity.data_response
      end
    end

    def add_code_assignments_error(coding_class, activity)
      if !activity.send(get_coding_classified_method(coding_class))
        coding_type        = get_coding_type(coding_class)
        coding_type_amount = activity.send(coding_type) || 0
        coding_amount      = activity.send("#{coding_class}_amount")
        coding_amount      = 0 if coding_amount.nil?
        difference         = coding_type_amount - coding_amount
        percent_diff       = difference/coding_type_amount * 100
        coding_type_amount = n2c(coding_type_amount)
        coding_amount      = n2c(coding_amount)
        difference         = n2c(difference)
        percent_diff       = n2c(percent_diff)

        return "We're sorry, when we added up your #{get_coding_name(coding_class)}
               classifications, they equaled #{coding_amount} but the #{coding_type}
               is #{coding_type_amount} (#{coding_type_amount} - #{coding_amount}
               = #{difference}, which is ~#{percent_diff}%). The total classified
               should add up to #{coding_type_amount}."
      end
    end

    def get_coding_name(klass)
      case klass.to_s
      when 'CodingBudget'
        'Budget by Purposes'
      when 'CodingBudgetDistrict'
        'Budget by Locations'
      when 'CodingBudgetCostCategorization'
        'Budget by Inputs'
      when 'ServiceLevelBudget'
        'Budget by Service Level'
      when 'CodingSpend'
        'Spent by Purposes'
      when 'CodingSpendDistrict'
        'Spent by Locations'
      when 'CodingSpendCostCategorization'
        'Spent by Inputs'
      when 'ServiceLevelSpend'
        'Spend by Service Level'
      end
    end

    def get_coding_classified_method(klass)
      case klass.to_s
      when 'CodingBudget'
        :coding_budget_classified?
      when 'CodingBudgetDistrict'
        :coding_budget_district_classified?
      when 'CodingBudgetCostCategorization'
        :coding_budget_cc_classified?
      when 'ServiceLevelBudget'
        :service_level_budget_classified?
      when 'CodingSpend'
        :coding_spend_classified?
      when 'CodingSpendDistrict'
        :coding_spend_district_classified?
      when 'CodingSpendCostCategorization'
        :coding_spend_cc_classified?
      when 'ServiceLevelSpend'
        :service_level_spend_classified?
      end
    end

    def load_data_response
      @data_response = @activity.data_response
    end
end
