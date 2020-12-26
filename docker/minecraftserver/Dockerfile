# no frills vanilla java minecraft server #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

# install & cleanup #

# cron is optional. in my case i insert a root crontab to backup the world
# regularly. if you choose to not install cron and backup another way then 
# make sure to adjust the systemd service file to not try to start the cron
# process

# rsync is also optional. depends on if you want ramdisk capability

RUN apt update && apt install -y --no-install-recommends \
	openjdk-14-jre-headless \
	screen \
	wget \
	rsync \
	cron && \
	apt clean && rm -r /var/lib/apt/lists/*

# insert config files and modify permissions as needed #

COPY minecraft /etc/init.d/minecraft
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /etc/init.d/minecraft && \
	chmod 755 /entrypoint.sh
