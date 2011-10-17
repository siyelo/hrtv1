module Shared::OutlaysHelper
  def sorted_project_select(response, klass, length = 60)
    list = response.projects.sort_by{ |p| p.name }.collect do |u|
      [ truncate(u.name, :length => length), u.id ]
    end
    list = list.insert(0,["<Automatically create a project for me>", -1])
    list = list.insert(1,["<No project>", nil]) if klass == "OtherCost"
    [['Select a project...', '']] + list
  end
end
