require 'iconv'

class Importer

  attr_accessor :response, :file, :filename, :projects, :activities, :new_splits

  def initialize(response, filename)
    @response = response
    @filename = filename
    begin
      worksheet = Spreadsheet.open(@filename).worksheet(0)
      @file = create_hash_from_header(worksheet)
    rescue Ole::Storage::FormatError
      # try import the file as a csv if it is not an spreadsheet
      @file = FasterCSV.open(@filename, {:headers => true, :skip_blanks => true})
    end
    @projects = @activities = @new_splits = []
  end

  def import
    @activities = []
    @projects = []
    activity_name = project_name = sub_activity_name = ''
    project_description = activity_description = ''
    @new_splits = []

    @file.each do |row|
      #determine project & activity details depending on blank rows
      activity_name        = name_for(row['Activity Name'], activity_name)
      activity_description = description_for(row['Activity Description'],
                                             activity_description, row['Activity Name'])
      project_name         = name_for(row['Project Name'], project_name)
      project_description  = description_for(row['Project Description'],
                                            project_description, row['Project Name'])

      sub_activity_name   = EncodingHelper::sanitize_encoding(row['Implementer'].try(:strip))
      sub_activity_id     = row['Id']

      # find implementer based on name or set self-implementer if not found
      # or row is left blank
      implementer = find_implementer(sub_activity_name)

      split = nil
      activity = nil
      project = nil

      # try find the split based on the id
      # use the association, not AR find, so we reference the same object

      # activity = find_existing_split_from_cache(@activites,sub_activity_)

      split = find_cached_split_using_split_id(sub_activity_id)
      activity = find_cached_activity_using_split_id(sub_activity_id)

      begin
        split = SubActivity.find(sub_activity_id) unless split
      rescue ActiveRecord::RecordNotFound
        #go on and try to find the activity or project
      end

      #split ID is present and valid - use split's activity & project
      if split && split.response == @response
        activity = split.activity unless activity
        project  = activity.project
      else
        # split ID not present or invalid
        # try find activity from activities in memory,
        @activities.each do |a|
          if a.name == activity_name && a.project.name == project_name
            activity = a
            project = a.project
          end
        end

        #if activity not found in memory, try find the project in memory
        @projects.each do |p|
          project = p if p.name == project_name
        end

        project = @response.projects.find_by_name(project_name) unless project
        project = @response.projects.new unless project
        activity = project.activities.find_by_name(activity_name) unless activity
        activity = Activity.new unless activity
        activity.project = project
        split = activity.implementer_splits.find(:first,
                        :conditions => { :provider_id => implementer.id}) if implementer
        unless split
          split = SubActivity.new # dont use activity.implementer_splits.new as it loads a new
                                  # association object
          split.activity = activity
          @new_splits << split
        end
      end

      # at this point, we should have an activity, and since we save everything via activity,
      # we need to use the activity objects

      # try find the split based on the id
      # use the association, not AR find, so we reference the same object
      activity.implementer_splits.each do |a|
        if a.id == split.id
          split = a
          break
        end
      end

      project.data_response       = @response
      project.name                = project_name
      project.description         = project_description.try(:strip)
      project.updated_at          = Time.now
      project.start_date          = date_for(row['Project Start Date'], project.start_date)
      project.end_date            = date_for(row['Project End Date'], project.end_date)
      # if its a new record, create a default in_flow so it can be saved
      if project.in_flows.empty?
        ff                        = project.in_flows.new
        ff.organization_id_from   = project.organization.id
        ff.spend                  = 0
        ff.budget                 = 0
        project.in_flows << ff
      end

      activity.data_response = @response
      activity.project       = project
      activity.name          = activity_name
      activity.description   = activity_description.try(:strip)
      activity.updated_at    = Time.now
      split.provider      = implementer
      split.data_response = @response
      split.spend         = row["Past Expenditure"]
      split.budget        = row["Current Budget"]
      split.updated_at    = Time.now # always mark it as changed, so it doesnt get hosed below

      trigger_errors(project, activity, split)

      @activities << activity unless @activities.include?(activity)
      @projects << project unless @projects.include?(project)
    end

    @activities.each_with_index do |la, i|
      # blow away any splits that werent modified by upload
      la.implementer_splits.each_with_index do |split, j|
        la.implementer_splits[j] = nil unless split.changed?
      end
      la.implementer_splits.compact! # remove any nils
      # we're not saving the activity yet, but we want to make sure the cached totals
      # from implementer_splits are up to date
      la.update_implementer_cache
    end

    # the new split objects wont be associated with their parent activites until you assign them
    # via the association. But, doing so any earlier saves all the changed records, so we
    # cant tell which unmodified splits to delete
    # So after clearing out the unwanted existing splits (above), we save in the brand new splits
    @new_splits.each do |split|
      split.activity.implementer_splits << split # does a save
      split.activity.save
    end

    return @projects, @activities
  end

  def name_for(current_row_name, previous_name)
    name = EncodingHelper::sanitize_encoding(current_row_name.blank? ? previous_name : current_row_name)
    name = name.strip.slice(0..Project::MAX_NAME_LENGTH-1).strip # strip again after truncation in case there are
                                                                 # any trailing spaces
  end

  # return the previous description only if both description and name
  # from current row are blank
  def description_for(description, previous_description, name)
    result = description
    if description.blank? && name.blank?
      result = previous_description
    end
    EncodingHelper::sanitize_encoding(result)
  end

  def date_for(date_row, existing_date)
    if date_row.blank? && existing_date
      date = existing_date
    else
      date = DateHelper::flexible_date_parse(date_row)
    end
    date
  end

  def find_implementer(implementer_name)
    implementer = @response.organization
    unless implementer_name.blank?
      implementer = Organization.find(:first, :conditions => [ "LOWER(name) LIKE ?",
          "%#{implementer_name.try(:downcase)}%"]) || implementer
    end
    implementer
  end

  def find_cached_split_using_split_id(implementer_split_id)
    find_cached_objects_using_split_id(implementer_split_id)[0]
  end

  def find_cached_activity_using_split_id(implementer_split_id)
    find_cached_objects_using_split_id(implementer_split_id)[1]
  end

  def find_cached_objects_using_split_id(implementer_split_id)
    split = nil
    activity = nil
    @activities.each do |la|
      la.implementer_splits.each do |a|
        if a.id == implementer_split_id.to_i #TODO - catch exceptions on "garbageinput".to_i
          split = a
          break
        end
      end
      if split #found one
        activity = la # just reference the exsiting object
        break
      end
    end
    [split, activity]
  end

  def trigger_errors(project, activity, split)
    project.valid?
    activity.valid?
    split.valid?
  end

  def create_hash_from_header(xls_worksheet)
    file = []
    header = []
    xls_worksheet.each_with_index do |row, row_index|
      if row_index == 0
        header = row
      else
        h = Hash.new
        row.each_with_index do |cell, col_index|
          h[header[col_index]] = cell
        end
        file << h
      end
    end
    file
  end

end

