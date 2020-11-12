# no frills repository mythtv backend #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

# needed for tzdata
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
	apt full-upgrade -y && \
	apt install -y curl && \
	ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

RUN apt install -y --no-install-recommends \
	ssh \
	x11-apps \
	sudo \
	xauth \
	xvfb \
	xmltv-util \
	mythtv-backend && \
	apt clean && \
	rm -r /var/lib/apt/lists/* && \
	echo "mythtv ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/mythtv
		
# get current minecraft server jar file #

COPY config.xml /etc/mythtv/config.xml
COPY sshd_config /etc/ssh/sshd_config
RUN usermod -aG sudo mythtv && \
	chown mythtv:mythtv /etc/mythtv/config.xml && \
	echo "mythtv:mythtv" | chpasswd
