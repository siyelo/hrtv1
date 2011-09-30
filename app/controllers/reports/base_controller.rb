class Reports::BaseController < ApplicationController
  include PrepareCharts
  before_filter :require_user
  before_filter :warn_if_not_current_request

  private
    def check_district_reports_access_for_location(location_id)
      if (current_user.district_manager? && current_user.location_id.to_s != location_id)
        restrict_district_manager_access
      end
    end

    def restrict_district_manager_access
      # restrict access only if user is district manager
      if (!current_user.reporter? && !current_user.activity_manager? &&
          !current_user.sysadmin?) && current_user.district_manager?
        raise AccessDenied
      end
    end

    def require_country_reports_permission
      unless (current_user.reporter? || current_user.activity_manager? || current_user.sysadmin?)
        raise AccessDenied
      end
    end
end
