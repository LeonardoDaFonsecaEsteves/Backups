#/bin/bash
# Backups for bdd and upload folder backups in dorpbox
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
    echo "Deleting $OUTPUT/*.sql.gz older than $KEEP_BACKUPS_FOR days"
    find $OUTPUT -type f -name "*.sql.gz" -mtime +$KEEP_BACKUPS_FOR -exec rm {} \;
}

## dumping bdd
backup_databases() {
    databases=$(mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)
    for db in $databases; do
        # exclude schema mysql phpmyadmin
        if ! echo "$db" | grep -q "schema\|mysql\|phpmyadmin"; then
            echo "Dumping database: $db"
            mysqldump --force --opt --routines --user=$USER --password=$PASSWORD --databases $db >$OUTPUT/$TIMESTAMP.$db.sql
            gzip $OUTPUT/$TIMESTAMP.$db.sql
        fi
    done
}

## upload in dropbox
upload_backups() {
    # compress backups folder
    tar -cv $OUTPUT | gzip >backups.tar.gz
    ./dropbox_uploader.sh upload backups.tar.gz /backups
}

#==============================================================================
# RUN SCRIPT
#==============================================================================
delete_old_backups >> logs/logs.$TIMESTAMP.txt
backup_databases >> logs/logs.$TIMESTAMP.txt
upload_backups >> logs/logs.$TIMESTAMP.txt
