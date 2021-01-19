#!/bin/sh
# tadaen sylvermane | jason gibson

# begin script #

# create my configuration #

for file in $(find /var/lib/mysql/ -maxdepth 1 -mindepth 1) ; do
	case $(basename "$file") in
	mysql_upgrade_info|debian-10.3.flag)
		continue
		;;
	*)
		chown -R mysql:mysql "$file"
		;;
	esac
done

echo "[mysqld]
optimizer_search_depth = 1
skip-name-resolve
innodb_adaptive_hash_index = off
bind-address            = 0.0.0.0
sort_buffer_size = 16M" > /etc/mysql/mariadb.conf.d/99-optimize.cnf

# set tzdata if needed - this is needed for the mythtv backend, possibly other things#

if [ ! -e /var/lib/mysql/.tzdatalockDNR ] ; then
	service mysql start && mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql mysql
	touch /var/lib/mysql/.tzdatalockDNR && service mysql stop
fi

service mysql start && bash

# end script #
