# backs up a heroku app db to sqlite3 using heroku db:pull
APP='resourcetracking'
BUNDLE='rtbackup'
OLD_BUNDLE=`heroku bundles --app $APP | awk '{print $1}'`
DATE=`date '+%Y-%m-%d-%I%Mhrs'`
BACKUP_DIR=/root/hrt_backups/
BACKUP_DB_FILE=$BACKUP_DIR/$APP-backup.$DATE.db

echo ""
echo ""
echo "$DATE: Backing up $APP..."

echo "  Doing db:pull to sqlite3..."

# gifted 'expect' idea from http://trnsfrmr.com/2010/08/23/automate-dbpull-from-heroku/
expect -c "
#Your timeout should correspond to the number of seconds you expect pull to take.
set timeout 600
spawn heroku db:pull sqlite://$BACKUP_DB_FILE --app $APP
expect \"Are you sure you wish to continue? (y/n)? \"
send \"y\r\"
set results $expect_out(buffer)
expect eof"
date >> /home/www/sites/xxx/db/backuplog.log
echo "  db pull done at `date '+%Y-%m-%d-%I%Mhrs'`"

echo "...done"
echo ""
