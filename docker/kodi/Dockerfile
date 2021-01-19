# Kodi docker for remote pulse playback #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

# needed for tzdata
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

COPY entrypoint.sh /entrypoint.sh

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
	gnupg \
	curl && \
	ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime && \
	echo "deb http://ppa.launchpad.net/team-xbmc/ppa/ubuntu focal main" >> /etc/apt/sources.list && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 189701DA570C56B9488EF60A6D975C4791E7EE5E

RUN apt update && apt install -y --no-install-recommends \
	patch \
	pulseaudio \
	x11vnc \
	xvfb \
	kodi \
	kodi-eventclients-kodi-send && \
	apt --purge -y autoremove software-properties-common && \
	rm -r /var/lib/apt/lists/* && \
	chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
