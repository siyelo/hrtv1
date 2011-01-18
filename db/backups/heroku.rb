#!/usr/bin/env ruby

#
# Back up a heroku app
#  1. To postgres using pgbackup
#  2. To sqlite3 using heroku db:pull
#

def run(cmd)
  puts cmd + "\n"
  system cmd
end

def get_date
  `date '+%Y-%m-%d-%H%Mhrs'`.chomp
end

args       = ARGV.join(' ')
APP        = ARGV[0] || 'resourcetracking'
BACKUP_DIR = ARGV[1] || '/root/hrt_backups/'

date           = get_date()
backup_db_file = "#{BACKUP_DIR}/#{APP}-backup.#{date}.pgbackup.db"

puts "*** #{date}: Backup of #{APP} started... ***"

puts "  Starting pgbackup to #{backup_db_file}..."
run "heroku pgbackups:capture --expire --app #{APP}"
url = `heroku pgbackups:url --app #{APP}`
run "curl -o #{backup_db_file} #{url}"
sleep 10 #curl returning before done ?
run "gzip #{backup_db_file}"

date           = get_date()
backup_db_file = "#{BACKUP_DIR}/#{APP}-backup.#{date}.sqlite3.db"

puts "  Starting sqlite backup to #{backup_db_file}..."
run "heroku db:pull sqlite://#{backup_db_file} --app #{APP} --confirm #{APP}"
puts "  ...sqlite backup done at #{get_date}"
run "gzip #{backup_db_file}"

puts "... backup done.\n\n"


