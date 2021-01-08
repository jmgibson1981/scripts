#!/bin/sh
# tadaen sylvermane | jason gibson

# variables #

CRONTAB=/var/spool/cron/crontabs/root

# create crontab #

echo "*/10 * * * *	service minecraft backup
25 */12 * * *	service minecraft update" >> "$CRONTAB"
chmod 600 "$CRONTAB" && chown root:crontab "$CRONTAB"


echo '#!/bin/sh
# /etc/init.d/minecraft
# version 1.2

# 1.2 changes - added backup to the usage statement.
# adjusted hard backups to every 8 hours from 12 hours.
# added jar file updating function and adjusted mc_stop to include it for
# automatic run via cron.

# sourced and modified from
# https://minecraft.gamepedia.com/Tutorials/Server_startup_script#Init.d_Script

### BEGIN INIT INFO
# Provides:   minecraft
# Required-Start: $local_fs $remote_fs screen-cleanup
# Required-Stop:  $local_fs $remote_fs
# Should-Start:   $network
# Should-Stop:    $network
# Default-Start:  2 3 4 5
# Default-Stop:   0 1 6
# Short-Description:    Minecraft server
# Description:    Starts the minecraft server
### END INIT INFO

# as this is a docker container init script i saw no reason to not run the
# worlds as root

#Settings
WORLDS="/var/lib/minecraft"
CURRENT="$(uname -n)"
NOW="$(date +%Y.%m.%d.%H.%M)"
BACKUPDIR="/var/lib/minecraft/BACKUPS"
JARFILE="${WORLDS}/SERVER.jar"
JAVAOPTS="nogui"

mc_start_cmd() {
	screen -dmS "$CURRENT" java -jar "$JARFILE" "$JAVAOPTS"
}

# this function in particular determines what type of server you run. it sources
# from an environment folder that exists in the /var/lib/minecraft/ENVFOLDER.
# this folder should be accessible on the host as well, in my case the hosts
# docker volume that contains the worlds. the systemd service on the host pulls 
# from this same file when starting the container for setting necessary ports.

mc_server_customize() {
	SERVFILE="$WORLDS"/"$CURRENT"/server.properties
	if [ ! -f "$SERVFILE" ] ; then
		cp "$WORLDS"/ENVFOLDER/server.properties.base "$SERVFILE"
		. "$WORLDS"/ENVFOLDER/"$CURRENT"
		# game type
		sed -i "s/gamemode=survival/gamemode=${GAMETYPE}/g" "$SERVFILE"
		# difficulty
		sed -i "s/difficulty=easy/difficulty=${DIFFICULTY}/g" "$SERVFILE"
		# players
		sed -i "s/max-players=20/max-players=${PLAYERS}/g" "$SERVFILE"
		# world name
		sed -i "s/level-name=world/level-name=${WORLDNAME}/g" "$SERVFILE"
		# eula setting
		echo "eula=true" > "$WORLDS"/"$CURRENT"/eula.txt
		# ramdisk
		if [ "$RAMDISK" = yes ] ; then
			touch "$WORLDS"/"$CURRENT"/.ramdisk
			[ -d "$WORLDS"/RAMDISK ] || mkdir -p "$WORLDS"/RAMDISK
		fi
	fi
}

mc_server_start() {
	[ -e "$JARFILE" ] || mc_jar_update
	# checks screen to make sure world not running
	if ! screen -ls | grep "$CURRENT" ; then
		# makes world directory if needed
		[ -d "$WORLDS"/"$CURRENT" ] || mkdir -p "$WORLDS"/"$CURRENT"
		# runs function to customize world. only runs if new world
		mc_server_customize
		# start world
		if [ -e "$WORLDS"/"$CURRENT"/.ramdisk ] ; then
			rsync -au "$WORLDS"/"$CURRENT" "$WORLDS"/RAMDISK/
			cd "$WORLDS"/RAMDISK/"$CURRENT" && mc_start_cmd
		else
			cd "$WORLDS"/"$CURRENT" && mc_start_cmd
		fi
	fi
}

mc_screen_cmd_func() {
	# the original init script i sourced from had this same screen command many 
	# times. made more sense to make it a function to me
	screen -p 0 -S "$CURRENT" -X eval "stuff \"${1}\"\015"
}

mc_backup_func() {
	# forces a write to the disk and makes world read only temporarily.
	mc_screen_cmd_func "save-off"
	mc_screen_cmd_func "save-all"
	sync
	sleep 10
	# backs up ramdisk world to hard storage volume
	if [ -e "$WORLDS"/"$CURRENT"/.ramdisk ] ; then
		rsync -au "$WORLDS"/RAMDISK/"$CURRENT" "$WORLDS"/
	fi
	# this is set to backup to a tar.gz file at 0300 and 1500 respectively. every
	# 12 hours. can make more often as needed by modifying case call
	case "$(date +%H%M)" in
		0300|1500)
			mc_screen_cmd_func "say backing up"
			[ -d "$BACKUPDIR" ] || mkdir -p "$BACKUPDIR"
			tar -czf "$BACKUPDIR"/"$CURRENT"."$NOW".tar.gz "$WORLDS"/"$CURRENT"/*
			# removes any backups older than n days
			find "$BACKUPDIR"/ -type f -mtime +5 -exec rm {} \;
			;;
	esac
	if [ "$1" = stop ] ; then
		for seconds in 15 10 5 ; do
			mc_screen_cmd_func "say stopping in ${seconds}"
			sleep 5
		done
		mc_screen_cmd_func "stop"
		# this little thing cleans up the ramdisk as needed
		if [ -e "$WORLDS"/RAMDISK/"$CURRENT" ] ; then
			until ! screen -ls | grep "$CURRENT" ; do
				sleep 5
			done
			rm -r "$WORLDS"/RAMDISK/"$CURRENT"
		fi
	else
		# re-enables world saving
		mc_screen_cmd_func "save-on"
	fi
}

mc_world_status() {
	# basic test to check if running or not
	if screen -ls | grep "$CURRENT" > /dev/null ; then
		echo "${CURRENT} is running"
	else
		echo "${CURRENT} has stopped"
	fi
}

mc_jar_update() {
	wget -O - https://www.minecraft.net/en-us/download/server > /tmp/mcserver
	grep minecraft_server.[1-9] /tmp/mcserver > /tmp/mcservertype
	while IFS="\"" read -r trash1 info trash2 ; do
		wget -O "$JARFILE".tmp "$info" && break ; done < /tmp/mcservertype
	rm /tmp/mcserver /tmp/mcservertype
	CURRENTFILE=$(sha1sum "$JARFILE" | cut -d ' ' -f 1)
	NEWFILE=$(sha1sum "$JARFILE".tmp | cut -d ' ' -f 1)
	if [ "$CURRENTFILE" != "$NEWFILE" ] ; then
		if [ -f "$JARFILE" ] ; then
			mv "$JARFILE".tmp "$JARFILE"
		else
			mc_backup_func stop
			mv "$JARFILE".tmp "$JARFILE"
			mc_server_start
		fi
	fi
}

case "$1" in
	start)
		mc_server_start
		;;
	stop)
		mc_backup_func stop
		;;
	restart)
		mc_backup_func stop
		mc_server_start
		;;
	backup)
		mc_backup_func
		;;
	status)
		mc_world_status
		;;
	update)
		mc_jar_update
		;;
	*)
		echo "Usage: ${0} (start|stop|restart|status|backup|update)"
		exit 1
		;;
esac

exit 0' > /etc/init.d/minecraft

# start services #

service cron start
service minecraft start

# tail off #

exec bash
