#!/usr/bin/env bash
set -e

function chown_if_possible() {
  local file="$1"
  chown -h bacliup:bacliup "$file" || echo "Skipped changing ownership of ${file}."
}

uid_or_gid_changed=

gid=$(id -g bacliup)
if [ -n "$BACLIUP_GID" ] && [ "$gid" != "$BACLIUP_GID" ]; then
  echo "Changing bacliup group GID from ${gid} to ${BACLIUP_GID}..."
  gid="${BACLIUP_GID}"
  groupmod -g "$gid" bacliup
  uid_or_gid_changed=1
fi

uid=$(id -u bacliup)
if [ -n "$BACLIUP_UID" ] && [ "$uid" != "$BACLIUP_UID" ]; then
  echo "Changing bacliup user UID from ${uid} to ${BACLIUP_UID}..."
  uid="${BACLIUP_UID}"
  usermod -u "$uid" bacliup
  uid_or_gid_changed=1
fi

if test -n "$uid_or_gid_changed"; then
  export -f chown_if_possible
  for dir in /bacliup /etc/bacliup /var/lib/bacliup; do
    echo "Updating ownership of bacliup files in ${dir}..."
    find "$dir" -xdev -exec bash -c 'chown_if_possible "$@"' bash {} \;
  done
fi

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
