# Backups scripts

##  Backups scripts is a bash script for servers it creates a backup of the databasse and upload folder in your dropbox accounts

***

# Change this configuration for you

``` bash
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
```

***

### This script use [Dropbox-Uploader](https://github.com/andreafabrizi/Dropbox-Uploader)

### Thanx for Andreafabrizi
