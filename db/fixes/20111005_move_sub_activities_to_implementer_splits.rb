total = SubActivity.count
current_number = 0
if total > 0
  SubActivity.all.each do |sa|
    @is = ImplementerSplit.new(:activity_id => sa.activity_id, :organization_id => sa.provider_id,
                             :spend => sa.spend, :budget => sa.budget)
    @is.save(false)
    current_number += 1
    p "#{current_number} / #{total}"
  end
  SubActivity.delete_all
else
  p "No sub activities to move"
end


