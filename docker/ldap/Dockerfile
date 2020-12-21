# no frills repository installation of mariadb-server #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

# needed for tzdata
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

ENV DEBIAN_FRONTEND=noninteractive
#RUN apt update && apt install -y \
#	curl && \
#	ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

# install & cleanup #

RUN apt update && apt install -y --no-install-recommends \
	slapd \
	ldap-utils \
	phpldapadmin
	
# create configuration files #
