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
        SubActivity.create_from_file(@activity, doc)
        flash[:notice] = 'Implementers were successfully uploaded.'
      else
        flash[:error] = 'Please select a file to upload implementers.'
      end
    rescue FasterCSV::MalformedCSVError
      flash[:error] = 'Your CSV file does not seem to be properly formatted.'
    end

    redirect_to edit_response_activity_path(@activity.data_response, @activity)
  end

  private
    def load_activity
      @activity = Activity.find(params[:activity_id])
    end
end
