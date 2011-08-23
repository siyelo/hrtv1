
def median(x)
  sorted = x.sort
  mid = x.size/2
  sorted[mid]
end

def coding_diff_report(budget_method, spend_method)
  diffs = []
  Activity.only_simple.with_request(DataRequest.first).each do |a| #Activity.only_simple.each do |a|
    diff = ((a.send(budget_method) || []) - (a.send(spend_method) || [])).count.abs || 0
    diffs << diff if diff > 0
  end
  puts "percentage with different #{spend_method.to_s} and #{budget_method.to_s}: #{(diffs.count.to_f / Activity.only_simple.with_request(DataRequest.first).count.to_f) * 100}"
  puts "average variance: #{diffs.sum/diffs.count}"
  puts "median variance: #{median(diffs)}"
end

[[:budget_purposes, :spend_purposes],
 [:budget_locations, :spend_locations],
 [:budget_ccs, :spend_ccs]].each do |method_pair|
   coding_diff_report(method_pair[0], method_pair[1])
end