#!/bin/sh
# tadaen sylvermane | jason gibson

# variables #

STORAGEFOLDER=/var/lib/mythtv
CRONTAB=/var/spool/cron/crontabs/root

# functions #

# sql server #

local_sql_config_func() {
	for file in $(find /var/lib/mythtv/sql/ -maxdepth 1 -mindepth 1) ; do
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
port = 33066
optimizer_search_depth = 1
skip-name-resolve
innodb_adaptive_hash_index = off
sort_buffer_size = 16M
datadir = ${STORAGEFOLDER}/sql" > /etc/mysql/mariadb.conf.d/99-mythtv.cnf
	if [ ! -e "$STORAGEFOLDER"/sql/.tzdatalockDNR ] ; then
		mkdir -p "$STORAGEFOLDER"/sql
		chown -R mysql:mysql "$STORAGEFOLDER"/sql
		mysql_install_db --user=mysql --ldata="$STORAGEFOLDER"/sql/ --basedir=/usr
		service mysql start
		echo "CREATE DATABASE IF NOT EXISTS mythconverg;
CREATE USER IF NOT EXISTS 'mythtv'@'localhost' IDENTIFIED BY 'mythtv';
GRANT ALL ON mythconverg.* TO mythtv@localhost;
FLUSH PRIVILEGES;
GRANT CREATE TEMPORARY TABLES ON mythconverg.* TO 'mythtv'@'localhost';
FLUSH PRIVILEGES;
ALTER DATABASE mythconverg DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS 'backup'@'localhost' IDENTIFIED BY 'backup';
GRANT ALL ON *.* TO 'backup'@'localhost';
FLUSH PRIVILEGES;" > /tmp/mythdbsetup
		cat /tmp/mythdbsetup | mysql
		mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql mysql
		touch "$STORAGEFOLDER"/sql/.tzdatalockDNR
		service mysql stop
	fi
}

mythtv_config_func() {
	echo "<Configuration>
		<Database>
			<PingHost>1</PingHost>
			<Host>localhost</Host>
			<UserName>mythtv</UserName>
			<Password>mythtv</Password>
			<DatabaseName>mythconverg</DatabaseName>
			<Port>33066</Port>
		</Database>
		<WakeOnLAN>
			<Enabled>0</Enabled>
			<SQLReconnectWaitTime>0</SQLReconnectWaitTime>
			<SQLConnectRetry>5</SQLConnectRetry>
			<Command>echo 'WOLsqlServerCommand not set'</Command>
		</WakeOnLAN>
	</Configuration>" > /etc/mythtv/config.xml
	chown mythtv:mythtv /etc/mythtv/config.xml
	chown mythtv:mythtv "$STORAGEFOLDER"
	echo "mythtv ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/mythtv
	echo "mythtv:mythtv" | chpasswd
	chsh --shell /bin/bash mythtv
    for dir in $(find /var/lib/mythtv/ -mindepth 1 -maxdepth 1 -type d) ; do
		DIRNAME=$(basename "$dir")
		case "$DIRNAME" in
			sql)
				continue
				;;
			*)
				chown -R mythtv:mythtv /var/lib/mythtv/"$DIRNAME"
				;;
		esac
	done
}

ssh_config_func() {
	echo "Include /etc/ssh/sshd_config.d/*.conf
Port 22222
PasswordAuthentication yes
ChallengeResponseAuthentication no
PermitRootLogin yes
PasswordAuthentication yes
X11Forwarding yes
X11UseLocalhost yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem	sftp	/usr/lib/openssh/sftp-server" > /etc/ssh/sshd_config
}

crontab_config_func() {
	echo "00 02 * * 7	/root/optimize_mythdb.pl" > "$CRONTAB"
	echo "*/1 * * * *	/usr/bin/pgrep mythbackend || [ -f /run/mythtv/mythbackend.pid ] && /usr/bin/rm /run/mythtv/mythbackend.pid && /usr/sbin/service mythtv-backend start" >> "$CRONTAB"
	chown root:crontab "$CRONTAB" && chmod 600 "$CRONTAB"
}

# start up #

local_sql_config_func
mythtv_config_func
ssh_config_func
crontab_config_func


if [ -f /etc/mythtvenv/$(uname -n) ] ; then
	. /etc/mythtvenv/$(uname -n)
	sed -i "s/33066/${SQLPORT}/" /etc/mysql/mariadb.conf.d/99-mythtv.cnf
	sed -i "s/33066/${SQLPORT}/" /etc/mythtv/config.xml
	sed -i "s/22222/${SSHPORT}/" /etc/ssh/sshd_config
	sed -i "s/^ARGS=\"--daemon/ARGS=\"--override-setting MasterServerPort=${BackendServerPort} --override-setting BackendServerPort=${BackendServerPort} --override-setting BackendStatusPort=${BackendStatusPort} --daemon/" /etc/init.d/mythtv-backend
fi

[ -f /run/mythtv/mythbackend.pid ] && rm /run/mythtv/mythbackend.pid
service mysql start
service cron start
service ssh start
sleep 10
service mythtv-backend start
exec bash

# end script #
