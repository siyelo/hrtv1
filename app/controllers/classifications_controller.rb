class ClassificationsController < Reporter::BaseController
  before_filter :load_data_response

  def edit
    @projects = @response.projects.all
  end

  def update
    @activity = @response.activities.find(params[:activity_id])

    params[:classifications].each_pair do |code_id, value|
      code_assignments = @activity.code_assignments.with_type(params[:coding_type])
      ca = code_assignments.detect{|ca| ca.code_id == code_id.to_i}
      if value.to_s.last == '%'
        ca.percentage = value.to_s.delete('%')
        ca.amount = nil
      else
        ca.amount = value
        ca.percentage = nil
      end

      ca.save
    end

    @activity.update_classified_amount_cache(params[:coding_type].constantize)

    flash[:notice] = 'Purposes classifications for Spent were successfully saved'
    redirect_to edit_response_classifications_url(@response, :coding_type => params[:coding_type])
  end
end
