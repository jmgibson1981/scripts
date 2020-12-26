#!/bin/sh
# tadaen sylvermane | jason gibson

# variables #

CRONTAB=/var/spool/cron/crontabs/root

# create crontab #

echo "*/10 * * * *	service minecraft backup
25 */12 * * *	service minecraft update" >> "$CRONTAB"
chmod 600 "$CRONTAB" && chown root:crontab "$CRONTAB"

# start services #

service cron start
service minecraft start && bash
