#!/usr/bin/env bash
set -e

sudo -u bacliup /usr/local/bin/bacliup import-gpg

/usr/local/bin/bacliup init
crontab -l
echo

exec crond -f -l 6
