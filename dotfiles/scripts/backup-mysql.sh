#!/bin/bash
DATA=/var/lib/mysql
BACKUP_DBDIR=/home/backup/mysql
MYUSER=admin
MYPW=pass

mkdir -p $BACKUP_DBDIR/{databases,data}
for dbname in $(mysql -u $MYUSER -p$MYPW -e 'show databases' -s --skip-column-names | grep -vi 'information_schema\|performance_schema');
do
  printf "## Dump database $dbname...\n"
  mysqldump -u$MYUSER -p"$MYPW" -ql "$dbname" > "$BACKUP_DBDIR/databases/$dbname.sql"
done
cp -r $DATA $BACKUP_DBDIR/data
tar -zcvf $BACKUP_DBDIR/databases.tar.gz $BACKUP_DBDIR/databases
rm -rf $BACKUP_DBDIR/databases
tar -zcvf $BACKUP_DBDIR/data.tar.gz $BACKUP_DBDIR/data
rm -rf $BACKUP_DBDIR/data

