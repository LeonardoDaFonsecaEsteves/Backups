#/bin/bash
# Create by = Leonardo
# date = 16/11/2021

# usr bdd
USER="user_login"
# pass bdd
PASSWORD="user_passe"
# folder backups
OUTPUT="backups"
# YYYY-MM-DD
TIMESTAMP=$(date +%F)
# Number of days to keep backups
KEEP_BACKUPS_FOR=30

## delete backups old 30 days
delete_old_backups() {
    # delete old backups
    echo "Deleting $OUTPUT/*.sql.gz older than $KEEP_BACKUPS_FOR days"
    # execut rm for old backups
    find $OUTPUT -type f -name "*.sql.gz" -mtime +$KEEP_BACKUPS_FOR -exec rm {} \;
}

## dumping bdd
backup_databases() {
    databases=$(mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)
    for db in $databases; do
        # exclude schema mysql phpmyadmin
        if ! echo "$db" | grep -q "schema\|mysql\|phpmyadmin"; then
            echo "Dumping database: $db"
            # extract bdd content
            mysqldump --force --opt --routines --user=$USER --password=$PASSWORD --databases $db >$OUTPUT/$TIMESTAMP.$db.sql
            # compress content bdd
            gzip $OUTPUT/$TIMESTAMP.$db.sql
        fi
    done
}

## upload in dropbox
upload_backups() {
    # compress backups folder
    tar -cv $OUTPUT | gzip >backups.tar.gz
    # upload folder
    ./dropbox_uploader.sh upload backups.tar.gz /backups
}

#==============================================================================
# RUN SCRIPT
#==============================================================================
delete_old_backups > logs/logs.$TIMESTAMP.txt
backup_databases >> logs/logs.$TIMESTAMP.txt
upload_backups >> logs/logs.$TIMESTAMP.txt
