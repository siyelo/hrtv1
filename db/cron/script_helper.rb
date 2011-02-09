module ScriptHelper
  DEFAULT_PRODUCTION_APP = 'resourcetracking'

  def run(cmd)
    puts cmd + "\n"
    system cmd
  end

  def get_date
    `date '+%Y-%m-%d-%H%Mhrs'`.chomp
  end

end