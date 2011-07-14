class SubActivitiesController < Reporter::BaseController
  before_filter :load_activity

  def index
    template = SubActivity.download_template(@activity)
    send_csv(template, 'implementers_existing.csv')
  end

  def template
    template = SubActivity.download_template
    send_csv(template, 'implementers_template.csv')
  end

  def create
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        all_ok, @sa = SubActivity.create_sa(@activity, doc)
        message = @sa.empty? ? "Implementers were successfully uploaded." : "Not all Implementers could be resolved."
        flash[:notice] = message
        redirect_to edit_response_activity_path(@activity.data_response, @activity) if all_ok
      else
        flash[:error] = 'Please select a file to upload implementers.'
        redirect_to edit_response_activity_path(@activity.data_response, @activity)
      end
    rescue FasterCSV::MalformedCSVError
      flash[:error] = 'Your CSV file does not seem to be properly formatted.'
    end
  end
  
  def bulk_create
    params.each_key do |key|
      if key.to_i > 0
        @sa = SubActivity.new(params[key]) if key.to_i > 0
        @activity.sub_activities << @sa
      end
    end
    if @activity.save
      redirect_to edit_response_activity_path(@activity.data_response, @activity)
    else
      flash[:error] = "Please ensure all Implementers have providers"
      redirect_to :back
    end
  end

  private
    def load_activity
      @activity = Activity.find(params[:activity_id])
    end
end
