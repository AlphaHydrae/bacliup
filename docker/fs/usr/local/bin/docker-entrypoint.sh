#!/usr/bin/env bash
set -e

/usr/local/bin/dump-env \
  BACLIUP_BACKUP_CONFIGS_DIR \
  BACLIUP_BACKUP_NAME \
  BACLIUP_BACKUP_SCRIPT \
  BACLIUP_BACKUP_TO \
  BACLIUP_BACKUP_TO_PREFIX \
  BACLIUP_BACKUP_TO_SUFFIX \
  BACLIUP_BACKUP_TYPE \
  BACLIUP_CURL_BIN \
  BACLIUP_GPG_BIN \
  BACLIUP_GPG_RECIPIENT \
  BACLIUP_RCLONE_BIN \
  BACLIUP_RCLONE_CONFIG_FILE \
  BACLIUP_RCLONE_OPTIONS \
  BACLIUP_SLACK_WEBHOOK \
  BACLIUP_TAR_BIN \
  BACLIUP_TEMPLATES_DIR

/usr/local/bin/with-env sudo -u bacliup /usr/local/bin/bacliup import-gpg

/usr/local/bin/bacliup init
crontab -l
echo

exec crond -f -l 6
