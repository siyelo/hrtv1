# backs up a heroku app db to sqlite3 using heroku db:pull
APP='resourcetracking'
BACKUP_DIR=/root/hrt_backups/

echo ""
echo ""
echo "$DATE: Backing up $APP..."

DATE=`date '+%Y-%m-%d-%H%Mhrs'`
BACKUP_DB_FILE=$BACKUP_DIR/$APP-backup.$DATE.pgbackup.db
echo "  Starting pgbackup to $BACKUP_DB_FILE..."
heroku pgbackups:capture --expire --app $APP
curl -o $BACKUP_DB_FILE `heroku pgbackups:url --app $APP`
echo "  gzipping it"
gzip $BACKUP_DB_FILE

#for BACKUP_TYPE in sqlite postgres
for BACKUP_TYPE in sqlite
do
  DATE=`date '+%Y-%m-%d-%H%Mhrs'`
  BACKUP_DB_FILE=$BACKUP_DIR/$APP-backup.$DATE.$BACKUP_TYPE.db
  echo "  Starting db:pull backup to $BACKUP_DB_FILE..."
  # gifted 'expect' idea from http://trnsfrmr.com/2010/08/23/automate-dbpull-from-heroku/
  expect -c "
  #Your timeout should correspond to the number of seconds you expect pull to take.
  set timeout 600
  spawn heroku db:pull $BACKUP_TYPE://$BACKUP_DB_FILE --app $APP
  expect \"Are you sure you wish to continue? (y/n)? \"
  send \"y\r\"
  set results $expect_out(buffer)
  expect eof"
  echo "  $BACKUP_TYPE backup done at `date '+%Y-%m-%d-%H%Mhrs'`"
  echo "  gzipping it"
  gzip $BACKUP_DB_FILE
done

echo "...done"
echo ""
