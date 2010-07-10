class CodeAssignmentsController < ApplicationController

  def index
    #@projects = Projects.find_by_user(current_user)
    @activities = Activity.all
  end

  def manage

    #@activities = Activity.find(params[:activity_id])
    @activity = Activity.first

    Code.all.each do |code|
      @activity.code_assignments.build( :code => code ) unless @activity.code_assignments.map(&:code_id).include?(code.id)
    end
  end

end
