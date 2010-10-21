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
      Nsp.children.find(:all, 
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

  def print_code(csv, code, spaces=0)
    if code.leaf?
      code.code_assignments.each do |ca|
        empty = []
        (3-spaces).times{|i| empty << ''}
        spaces.times{|i| empty << code.parent.short_display}
        csv << empty.concat([code.id, code.short_display, ca.activity.try(:id), ca.activity.try(:budget), ca.activity.try(:spend)])
      end
    else
      spaces += 1
      code.children.each do |child|
        print_code(csv, child, spaces) 
      end
    end
  end

end
