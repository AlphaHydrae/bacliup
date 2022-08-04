#!/usr/bin/env bash
set -e

/usr/local/bin/bacliup cron | crontab -

crond -f -l 0
