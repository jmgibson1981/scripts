# no frills repository installation of mariadb-server #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

# needed for tzdata
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
		apt full-upgrade -y && \
		apt install -y curl && \
		ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

# install & cleanup #

RUN apt update && \
	apt full-upgrade -y && \
	apt install -y \
	--no-install-recommends \
	tzdata \
	mariadb-server && \
	apt clean && \
	rm -r /var/lib/apt/lists/*

# create configuration files #

COPY 99-kodi-optimize.cnf /etc/mysql/mariadb.conf.d/
COPY mysql /etc/init.d/mysql
RUN chmod 755 /etc/init.d/mysql

