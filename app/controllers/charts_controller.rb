class ChartsController < ApplicationController
  include StringCleanerHelper # gives h method
  TOP_ASSIGNMENTS = 4

  before_filter :require_user

  def data_response_pie
    @response    = find_response(params[:id])
    @assignments = Charts::DataResponsePies.data_response_pie(@response, params[:codings_type], params[:code_type])

    #/charts/data_response_pie?id=6586&codings_type=CodingBudget&code_type=CostCategory
    send_data(get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present')
  end

  def project_pie
    @project     = find_project(params[:id])
    @assignments = Charts::ProjectPies.project_pie(@project, params[:codings_type], params[:code_type])

    send_data(get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present')
  end

  def data_response_treemap
    data_response = DataResponse.find(params[:id])

    respond_to do |format|
      format.json { render :json => Charts::ActivityTreemaps.activities_treemap(data_response.activities, params[:chart_type]) }
    end
  end

  def project_treemap
    project = Project.find(params[:id])

    respond_to do |format|
      format.json { render :json => Charts::ActivityTreemaps.activities_treemap(project.activities, params[:chart_type]) }
    end
  end

  def activity_treemap
    activity = Activity.find(params[:id])

    respond_to do |format|
      format.json { render :json => Charts::ActivityTreemaps.activity_treemap(activity, params[:chart_type]) }
    end
  end

  private

  # csv format for AM pie chart:
  # title, value, ?, ?, ?, description
  def get_csv_string(records)
    other_total = 0
    csv_string = FasterCSV.generate do |csv|
      if records.present?
        records.each_with_index do |record, index|
          if index < TOP_ASSIGNMENTS
            csv << [first_n_words(h(record.name), 3), record.value.to_f,
                    nil, nil, nil, h(record.name) ]
          else
            other_total += record.value.to_f
          end
        end
        csv << ['Other', other_total, nil, nil, nil, 'Other'] if other_total > 0
      else
        csv << [] # when no data, add empty array so that flash chart doesn't cry
      end
    end

    csv_string
  end

  def first_n_words(string, n)
    words = string.split(' ')
    name = words.slice(0, n).join(' ')
    words.length <= n ? name : name + '...'
  end
end
