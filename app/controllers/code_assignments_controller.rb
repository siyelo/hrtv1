class CodeAssignmentsController < ApplicationController
  authorize_resource
  before_filter :load_activity

  def show
    authorize! :read, @activity
    @coding_type         = params[:coding_type] || 'CodingBudget'
    coding_class         = @coding_type.constantize
    @codes               = coding_class.available_codes(@activity)
    @current_assignments = coding_class.with_activity(@activity).all.map_to_hash{ |b| {b.code_id => b} }
    @error_message       = add_code_assignments_error(coding_class, @activity)
    @progress            = @activity.coding_progress
    if params[:tab].present?
      # ajax requests for all tabs except the first one
      render :partial => 'tab', :locals => {:coding_type => @coding_type,
                                            :activity => @activity,
                                            :codes => @codes,
                                            :tab => params[:tab] },
                                :layout => false
    else
      # show page with first tab loaded
      @model_help = ModelHelp.find_by_model_name 'CodeAssignment'
      render :action => 'show'
    end
  end

  def update
    authorize! :update, @activity
    notice_message = nil
    coding_class = params[:coding_type].constantize
    if params[:activity].present? && params[:activity][:updates].present?
      coding_class.update_codings(params[:activity][:updates], @activity)
      notice_message = "Activity classification was successfully updated. Please check that you have completed all the other tabs if you have not already done so."
    end
    @error_message = add_code_assignments_error(coding_class, @activity)
    respond_to do |format|
      format.html do
        flash[:error]  = @error_message if @error_message
        flash[:notice] = notice_message if notice_message
        redirect_to activity_coding_path(@activity)
      end
      format.js do
        @coding_type = params[:coding_type] || 'CodingBudget'
        coding_class = params[:coding_type].constantize
        @codes = coding_class.available_codes(@activity)
        @current_assignments = coding_class.with_activity(@activity).all.map_to_hash{ |b| {b.code_id => b} }
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
          redirect_to activity_coding_path(@activity)
        end
      else
        format.html do
          flash[:error] = "We could not copy your budget classifications across."
          redirect_to activity_coding_path(@activity)
        end
      end
    end
  end

  private

    def load_activity
      @activity = Activity.available_to(current_user).find(params[:activity_id])
    end

    def add_code_assignments_error(coding_class, activity)
      if !coding_class.classified(activity)
        coding_name = get_coding_name(coding_class)
        coding_type = get_coding_type(coding_class)
        coding_type_amount = activity.send(get_coding_type(coding_class))
        coding_amount = activity.send("#{coding_class}_amount")
        coding_amount = 0 if coding_amount.nil?
        difference = coding_type_amount - coding_amount
        percent_diff = difference/coding_type_amount * 100
        coding_type_amount = n2c(coding_type_amount)
        coding_amount = n2c(coding_amount)
        difference = n2c(difference)
        percent_diff = n2c(percent_diff)

        "We're sorry, when we added up your #{coding_name} classifications, they equaled #{coding_amount} but the #{coding_type} is #{coding_type_amount} (#{coding_type_amount} - #{coding_amount} = #{difference}, which is ~#{percent_diff}%). The total classified should add up to #{coding_type_amount}. You need to classify the total amount 3 times, in the coding, districts, and cost categories tabs."
      end
    end

    def get_coding_name(klass)
      case klass.to_s
      when 'CodingBudget'
        "Budget Coding"
      when 'CodingBudgetDistrict'
        "Budget by District"
      when 'CodingBudgetCostCategorization'
        "Budget by Cost Category"
      when 'CodingSpend'
        "Spent Coding"
      when 'CodingSpendDistrict'
        "Spent by District"
      when 'CodingSpendCostCategorization'
        "Spent by Cost Category"
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
end
