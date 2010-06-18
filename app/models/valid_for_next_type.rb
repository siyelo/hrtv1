class ValidForNextType < ActiveRecord::Base

  def children
    Code.find(children_src.map {|c| c.code_id_child})
  end

  private
  has_many :children_src, :class_name => "ValidForNextType", :foreign_key => "code_id_parent"
end
