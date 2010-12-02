class ProjectMover

  attr_accessor :source_response, :project, :target_response
  attr_reader :cloned_project

  def initialize(source_response, target_response, project)
    @source_response = source_response
    @project = project
    @target_response = target_response
  end

  def move!(check = true, validate = true )
    check_move() if check
    check_users_on_target_org() if check
    if @project && @project.data_response && @target_response
      from_org = @source_response.responding_organization
      to_org = @target_response.responding_organization
      puts "Moving Project: (#{@project.id}) \"#{@project.name.first(25)}...\", From Organization: (#{from_org.id}) #{from_org.name}, To Organization: (#{to_org.id}) #{to_org.name}"
      @cloned_project = @project.deep_clone
      @cloned_project.data_response = @target_response
      if validate
        @cloned_project.save!
      else
        @cloned_project.save(false)
      end
      puts "  ... Project (#{@project.id}) has been moved to New Project with id: #{@cloned_project.id}"
      raise "could not destroy project" unless @project.destroy
      puts "    Verify the move with users: #{@target_response.organization.users.collect.map(&:email).join(", ")}"
      @cloned_project
    end
  end

  def move_without_checks!
    self.move!(false)
  end

  def move_without_validations!
    self.move!(true, false)
  end

  def move_without_checks_and_validations!
    self.move!(false, false)
  end

  protected

    def check_move
      raise "source response (#{@source_response.id}) not found" unless DataResponse.find(@source_response)
      raise "project does not exist!" unless @project
      raise "project (#{@project.id}) data response does not exist" unless @project.try(:data_response)
      raise "project (#{@project.id}) is not part of source response (#{@source_response.id})" unless @project.data_response == @source_response
      raise "target response (#{@target_response.id}) not found" unless DataResponse.find(@target_response)
    end

    def check_users_on_target_org
      raise "No users exist on target organization - not moving" unless @target_response.responding_organization.users.size > 0
    end
end