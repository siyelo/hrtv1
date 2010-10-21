require 'fastercsv'

class Reports::ActivitiesByNsp < Reports::CodedActivityReport
  include Reports::Helpers

  #def initialize
    #@csv_string = FasterCSV.generate do |csv|
      #Nsp.roots.find(:all, 
                     #:include => [
                       #{:code_assignments => {:activity => :data_response}}, 
                       #{:children => [{:code_assignments => {:activity => :data_response}}, 
                         #{:children => [{:code_assignments => {:activity => :data_response}},
                           #{:children => [{:code_assignments => {:activity => :data_response}}]}
                         #]}
                       #]}
                    #]).each do |code|
        #print_code(csv, code)
      #end
    #end
  #end

  def initialize
    @csv_string = FasterCSV.generate do |csv|
      Nsp.leaves.find(:all, 
                     :include => [
                       {:code_assignments => {:activity => :data_response}}, 
                       {:parent => [{:code_assignments => {:activity => :data_response}}, 
                         {:parent => [{:code_assignments => {:activity => :data_response}},
                           {:parent => [{:code_assignments => {:activity => :data_response}}]}
                         ]}
                       ]}
                    ]).each do |code|
        print_code(csv, code)
      end
    end
  end

  def csv
    @csv_string
  end

  #def print_code(csv, code, spaces=0)
    #if code.leaf?
      #code.code_assignments.each do |ca|
        #empty = []
        #(3-spaces).times{|i| empty << ''}
        #spaces.times{|i| empty << code.parent.short_display}
        #csv << empty.concat([code.id, code.short_display, ca.activity.try(:id), ca.activity.try(:budget), ca.activity.try(:spend)])
      #end
    #else
      #spaces += 1
      #code.children.each do |child|
        #print_code(csv, child, spaces) 
      #end
    #end
  #end

  def print_code(csv, code)
    if code.code_assignments.empty?
      print_code(csv, code.parent) if code.parent && code.parent.type == 'Nsp'
    else
      code.code_assignments.each do |ca|
        csv << get_name(code).concat([ca.activity.try(:id), ca.activity.try(:name), ca.activity.try(:budget), ca.activity.try(:spend)])
      end
    end
  end

  def get_name(code)
    arr = []

    4.times do
      if code.type == 'Nsp'
        arr << code.short_display
      else
        arr << ''
      end

      code = code.parent
    end

    arr
  end

end
