class CodeAssignmentsController < ApplicationController

  def index
    #@projects = Projects.find_by_user(current_user)
    @activities = Activity.all
  end

  def manage
    @activities = Activity.all #TODO filter

    @activities.each do |a|
      Code.all.each do |code|
        a.code_assignments.build( :code => code ) unless a.code_assignments.map(&:code_id).include?(code.id)
      end
    end
  end

end
