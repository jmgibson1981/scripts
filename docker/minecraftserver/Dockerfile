# no frills repository minecraft server #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

# install & cleanup #

# cron is optional. in my case i insert a root crontab to backup the world
# regularly. if you choose to not install cron and backup another way then 
# make sure to adjust the systemd service file to not try to start the cron
# process

# rsync is also optional. depends on if you want ramdisk capability

RUN apt update && \
		apt full-upgrade -y && \
		apt install -y \
		--no-install-recommends \
		openjdk-14-jre-headless \
		screen \
		wget \
		rsync \
		cron && \
		apt clean && \
		rm -r /var/lib/apt/lists/*
		
# get current minecraft server jar file #

RUN wget -O - https://www.minecraft.net/en-us/download/server \
		> /tmp/mcserver && \
		grep minecraft_server.[1-9] /tmp/mcserver > /tmp/mcservertype && \
		while IFS='"' read -r trash1 info trash2 ; do \
		wget -O /root/server.jar "$info" && break ; done < /tmp/mcservertype && \
		rm /tmp/mcserver /tmp/mcservertype

# insert config files and modify permissions as needed #


COPY minecraft /etc/init.d/minecraft
COPY root /var/spool/cron/crontabs/root
RUN chmod 600 /var/spool/cron/crontabs/root \
	&& chown root:crontab /var/spool/cron/crontabs/root \
	&& chmod 755 /etc/init.d/minecraft
