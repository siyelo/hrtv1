class LongTermBudgetsController < Reporter::BaseController
  before_filter :load_current_response
  before_filter :load_organization

  def show
    @year = params[:id].to_i
  end

  private
    def load_organization
      @organization = current_user.organization
    end

    def load_current_response
      @response = current_user.current_response
    end
end
