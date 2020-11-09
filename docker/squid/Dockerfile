# no frills squid docker from repositories #
# minimum required to be able to run and configure #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

# needed for tzdata
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
	apt full-upgrade -y && \
	apt install -y curl && \
	ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

# install packages #

RUN apt install -y \
	--no-install-recommends \
	squid && \
	apt clean && \
	rm -r /var/lib/apt/lists/*



