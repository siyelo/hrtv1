#!/usr/bin/env ruby

#
# Back up a heroku app
#  1. To postgres using pgbackup
#  2. To sqlite3 using heroku db:pull
#
# Usage:
#   backup.rb HEROKU_APP DIR
# E.g.
#  backup.rb resourcetracking /backups
# or in crontab 7am & 11pm daily
#  0 7,23 * * * /root/health_resource_tracker/db/backups/heroku.rb resourcetracking ~/hrt_backups

def run(cmd)
  puts cmd + "\n"
  system cmd
end

def get_date
  `date '+%Y-%m-%d-%H%Mhrs'`.chomp
end

args       = ARGV.join(' ')
HEROKU_APP = ARGV[0] || 'resourcetracking'
BACKUP_DIR = ARGV[1] || '.'

date           = get_date()
backup_db_file = "#{BACKUP_DIR}/#{HEROKU_APP}-backup.#{date}.pgbackup.db".gsub('//','/')

puts "*** #{date}: Backup of #{HEROKU_APP} started... ***"

puts "  Starting pgbackup to #{backup_db_file}..."
run "heroku pgbackups:capture --expire --app #{HEROKU_APP}"
url = `heroku pgbackups:url --app #{HEROKU_APP}`.chomp
run "curl -o #{backup_db_file} '#{url}'"
run "gzip #{backup_db_file}"

date           = get_date()
backup_db_file = "#{BACKUP_DIR}/#{HEROKU_APP}-backup.#{date}.sqlite3.db"

puts "  Starting sqlite backup to #{backup_db_file}..."
run "heroku db:pull sqlite://#{backup_db_file} --app #{HEROKU_APP} --confirm #{HEROKU_APP}"
puts "  ...sqlite backup done at #{get_date}"
run "gzip #{backup_db_file}"

puts "... backup done.\n\n"


