#!/usr/bin/env bash
set -e

crontab="$(cat <<EOF
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * <command to execute>

# Hourly backup
0 * * * * /usr/local/bin/bacliup --to dest:hourly/${BACLIUP_BACKUP_NAME:-backup}/ &>/dev/stdout

# Daily backup
0 0 * * * /usr/local/bin/bacliup --to dest:daily/${BACLIUP_BACKUP_NAME:-backup}/ &>/dev/stdout

# Weekly backup
0 0 * * 0 /usr/local/bin/bacliup --to dest:weekly/${BACLIUP_BACKUP_NAME:-backup}/ &>/dev/stdout

# Monthly backup
0 0 1 * * /usr/local/bin/bacliup --to dest:monthly/${BACLIUP_BACKUP_NAME:-backup}/ &>/dev/stdout
EOF
)"

echo "$crontab" | crontab -

crond -f -l 0
