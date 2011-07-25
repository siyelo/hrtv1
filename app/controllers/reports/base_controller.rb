class Reports::BaseController < ApplicationController
  before_filter :require_user
  before_filter :warn_if_not_current_request

  private
    def get_code_type_and_initialize(code_type)
      case code_type
      when 'mtef'
        @mtef = true
      when 'cost_category'
        @cost_category = true
      when 'nsp', '', nil
        @nsp = true
        code_type = 'nsp'
      when 'hssp2_strat_prog'
        @hssp2_strat_prog = true
      when 'hssp2_strat_obj'
        @hssp2_strat_obj = true
      else
        raise "Invalid code type #{code_type}"
      end

      code_type
    end

    def get_chart_name(code_type)
      case code_type
      when 'mtef'
        'MTEF'
      when 'cost_category'
        'Inputs'
      when 'nsp', '', nil
        'NSP'
      when 'hssp2_strat_prog'
        'HSSP2 Strat Prog'
      when 'hssp2_strat_obj'
        'HSSP2 Strat Obj'
      else
        raise "Invalid code type #{code_type}"
      end
    end

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
