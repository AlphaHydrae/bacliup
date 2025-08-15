#!/usr/bin/env bash
set -e

if test -n "$BACLIUP_MINUTELY_TO"; then
  printf "Configuring minutely backups..."
  cron="${BACLIUP_MINUTELY_CRON:-"* * * * *"}"
  cat <<EOF | sudo -u bacliup tee -a /etc/bacliup/backups/minutely >/dev/null
to ${BACLIUP_MINUTELY_TO}
cron ${cron}
EOF
  echo ok
fi

if test -n "$BACLIUP_HOURLY_TO"; then
  printf "Configuring hourly backups..."
  minute="${BACLIUP_HOURLY_MINUTE:-0}"
  cron="${BACLIUP_HOURLY_CRON:-"${minute} * * * *"}"
  cat <<EOF | sudo -u bacliup tee -a /etc/bacliup/backups/hourly >/dev/null
to ${BACLIUP_HOURLY_TO}
cron ${cron}
EOF
  echo ok
fi

if test -n "$BACLIUP_DAILY_TO"; then
  printf "Configuring daily backups..."
  minute="${BACLIUP_DAILY_MINUTE:-15}"
  hour="${BACLIUP_DAILY_HOUR:-0}"
  cron="${BACLIUP_DAILY_CRON:-"${minute} ${hour} * * *"}"
  cat <<EOF | sudo -u bacliup tee -a /etc/bacliup/backups/daily >/dev/null
to ${BACLIUP_DAILY_TO}
cron ${cron}
EOF
  echo ok
fi

if test -n "$BACLIUP_WEEKLY_TO"; then
  printf "Configuring weekly backups..."
  minute="${BACLIUP_WEEKLY_MINUTE:-30}"
  hour="${BACLIUP_WEEKLY_HOUR:-0}"
  day_of_the_week="${BACLIUP_WEEKLY_DAY_OF_THE_WEEK:-0}"
  cron="${BACLIUP_WEEKLY_CRON:-"${minute} ${hour} * * ${day_of_the_week}"}"
  cat <<EOF | sudo -u bacliup tee -a /etc/bacliup/backups/weekly >/dev/null
to ${BACLIUP_WEEKLY_TO}
cron ${cron}
EOF
  echo ok
fi

if test -n "$BACLIUP_MONTHLY_TO"; then
  printf "Configuring monthly backups..."
  minute="${BACLIUP_MONTHLY_MINUTE:-45}"
  hour="${BACLIUP_MONTHLY_HOUR:-0}"
  day="${BACLIUP_MONTHLY_DAY:-0}"
  cron="${BACLIUP_MONTHLY_CRON:-"${minute} ${hour} ${day} * *"}"
  cat <<EOF | sudo -u bacliup tee -a /etc/bacliup/backups/monthly >/dev/null
to ${BACLIUP_MONTHLY_TO}
cron ${cron}
EOF
  echo ok
fi

sudo -u bacliup /usr/local/bin/bacliup import-gpg

/usr/local/bin/bacliup init
crontab -l
echo

exec crond -f -l 6
