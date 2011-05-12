class Reports::BaseController < ApplicationController
  layout 'reports'
  before_filter :require_user

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
end
