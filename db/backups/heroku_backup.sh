# backs up a heroku app db to sqlite3 using heroku db:pull
APP='resourcetracking'
BACKUP_DIR=/root/hrt_backups/

echo ""
echo ""
echo "$DATE: Backing up $APP..."

for BACKUP_TYPE in sqlite postgres
do
  DATE=`date '+%Y-%m-%d-%H%Mhrs'`
  BACKUP_DB_FILE=$BACKUP_DIR/$APP-backup.$DATE.$BACKUP_TYPE.db

  echo "  Starting db:pull backup to $BACKUP_TYPE..."

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
