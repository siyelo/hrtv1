class DatafixMoveProjectsFromMoh < ActiveRecord::Migration
  def self.up
    begin
      moh_dr   = DataResponse.find(6658)
      other_moh_dr   = DataResponse.find(6600)

      mover = ProjectMover.new(moh_dr, DataResponse.find(6665), Project.find(364))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6665), Project.find(570))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6664), Project.find(365))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6667), Project.find(387))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6661), Project.find(381))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6666), Project.find(398))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6663), Project.find(367))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6667), Project.find(385))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6667), Project.find(379))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6666), Project.find(488))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6666), Project.find(416))
      mover.move_without_validations!
      mover = ProjectMover.new(moh_dr, DataResponse.find(6662), Project.find(362))
      mover.move_without_validations!
      mover = ProjectMover.new(other_moh_dr, DataResponse.find(6663), Project.find(359))
      mover.move_without_validations!
    rescue Exception => e
      puts "\n ***** Cleanup of MoH projects failed. (Already done?). ***** \n"
      puts "\n *****   Error: #{e.message}\n\n"
    end
  end

  def self.down
  end

end
