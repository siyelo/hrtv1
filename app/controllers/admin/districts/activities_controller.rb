class Admin::Districts::ActivitiesController < ApplicationController
  before_filter :require_admin, :load_location

  def index
    @activities = @location.activities
  end

  def show
    @activity = Activity.find(params[:id])
    @mtef_spent_codings = CodingSpend.with_code_ids(Mtef.roots).with_activity(@activity)
    @mtef_budget_codings = CodingBudget.with_code_ids(Mtef.roots).with_activity(@activity)
  end

  protected

    def load_location
      @location = Location.find(params[:district_id])
    end
end
