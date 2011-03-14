class CodeAssignmentsController < ApplicationController
  layout 'reporter'
  authorize_resource
  before_filter :load_activity_and_data_response

  def show
    authorize! :read, @activity
    @coding_type         = params[:coding_type] || 'CodingBudget'
    @coding_class        = @coding_type.constantize
    @coding_tree         = CodingTree.new(@activity, @coding_class)
    @codes               = @coding_tree.root_codes
    @current_assignments = @coding_class.with_activity(@activity).all.map_to_hash{ |b| {b.code_id => b} }
    @error_message       = add_code_assignments_error(@coding_class, @activity)
    if params[:tab].present?
      render :partial => 'tab', :layout => false,
             :locals => {:coding_type => @coding_type, :activity => @activity,
                         :codes => @codes, :tab => params[:tab] }
    else
      @model_help = ModelHelp.find_by_model_name 'CodeAssignment'
      render :action => 'show'
    end
  end

  def update
    authorize! :update, @activity
    notice_message = nil
    @coding_class = params[:coding_type].constantize
    if params[:activity].present? && params[:activity][:updates].present?
      @coding_class.update_codings(params[:activity][:updates], @activity)
      notice_message = "Activity classification was successfully updated. Please check that you have completed all the other tabs if you have not already done so."
    end
    @error_message = add_code_assignments_error(@coding_class, @activity)
    respond_to do |format|
      format.html do
        flash[:error]  = @error_message if @error_message
        flash[:notice] = notice_message if notice_message
        redirect_to activity_code_assignments_url(@activity)
      end
      format.js do
        @coding_type         = params[:coding_type] || 'CodingBudget'
        @coding_class        = params[:coding_type].constantize
        @coding_tree         = CodingTree.new(@activity, @coding_class)
        @codes               = @coding_tree.root_codes
        @current_assignments = @coding_class.with_activity(@activity).all.map_to_hash{ |b| {b.code_id => b} }
        tab = render_to_string :partial => 'tab', :locals => { :coding_type => @coding_type, :activity => @activity, :codes => @codes, :tab => params[:tab] }
        tab_nav = render_to_string :partial => 'tab_nav', :locals => { :activity => @activity }
        activity_description = render_to_string :partial => 'activity_description', :locals => { :activity => @activity }
        render :json => {:message => {:error => @error_message, :notice => notice_message}, :tab => tab, :tab_nav => tab_nav, :activity_description => activity_description}.to_json
      end
    end
  end

  def copy_budget_to_spend
    authorize! :update, @activity
    respond_to do |format|
      if @activity.copy_budget_codings_to_spend([params[:coding_type]])
        format.html do
          flash[:notice] = "Budget classifications were successfully copied across."
          redirect_to activity_code_assignments_url(@activity)
        end
      else
        format.html do
          flash[:error] = "We could not copy your budget classifications across."
          redirect_to activity_code_assignments_url(@activity)
        end
      end
    end
  end

  def derive_classifications_from_sub_implementers
    authorize! :update, @activity
    respond_to do |format|
      if @activity.derive_classifications_from_sub_implementers!(params[:coding_type])
        format.html do
          flash[:notice] = "District classifications were successfully derived from sub implementers."
          redirect_to activity_code_assignments_url(@activity)
        end
      else
        format.html do
          flash[:error] = "We could not derive classification from sub implementers."
          redirect_to activity_code_assignments_url(@activity)
        end
      end
    end
  end

  private

    def load_activity_and_data_response
      @activity = Activity.available_to(current_user).find(params[:activity_id])
      @data_response = @activity.data_response
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
               should add up to #{coding_type_amount}. You need to classify the total
               amount 3 times, in the coding, districts, and cost categories tabs."
      end
    end

    def get_coding_name(klass)
      case klass.to_s
      when 'CodingBudget'
        "Budget by Purposes"
      when 'CodingBudgetDistrict'
        "Budget by Locations"
      when 'CodingBudgetCostCategorization'
        "Budget by Inputs"
      when 'CodingSpend'
        "Spent by Purposes"
      when 'CodingSpendDistrict'
        "Spent by Locations"
      when 'CodingSpendCostCategorization'
        "Spent by Inputs"
      end
    end

    def get_coding_type(klass)
      case klass.to_s
      when 'CodingBudget', 'CodingBudgetDistrict', 'CodingBudgetCostCategorization'
        :budget
      when 'CodingSpend', 'CodingSpendDistrict', 'CodingSpendCostCategorization'
        :spend
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
      when 'CodingSpend'
        :coding_spend_classified?
      when 'CodingSpendDistrict'
        :coding_spend_district_classified?
      when 'CodingSpendCostCategorization'
        :coding_spend_cc_classified?
      end
    end

    def load_data_response
      @data_response = @activity.data_response
    end

end
